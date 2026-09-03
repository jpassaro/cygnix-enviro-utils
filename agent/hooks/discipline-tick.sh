#!/usr/bin/env bash
# UserPromptSubmit + Stop hook: fires a discipline nudge every ~20 minutes
# (one pomodoro) of elapsed session time (rolling, not wall-clock-aligned —
# so it doesn't matter what minute the session started). Stateless
# timestamp injection (user-prompt-timestamp.sh) can't tell "time passed
# since we last checked"; this hook adds that missing delta.
#
# Also tracks continuous-stretch time, separate from the 20-minute check-in
# cadence: working an hour straight without stopping to stretch, check
# messages, or drink water is the failure mode, regardless of
# whether any timebox was declared or how "on track" the work is. A stretch
# is "continuous" until a real gap between hook invocations is seen (this
# hook fires on nearly every turn boundary, so a long gap is a good proxy
# for "the user actually stepped away") — UNLESS that gap is explained by a
# calendar meeting, which produces the same silent-gap signature without
# being restorative; see the meeting-covered check below.
#
# Polymorphic by hook_event_name (read from stdin JSON). Both branches set
# systemMessage — shown to the user directly by the harness, independent
# of anything Claude does — so Claude's job is no longer to *relay* the
# tick, it's to *act* on it (run the checks, then desk-log the result):
#   - UserPromptSubmit: hookSpecificOutput.additionalContext tells Claude
#     to run the checklist and desk-log a status line. Non-blocking —
#     Claude can fold this into its next reply.
#   - Stop: decision:block + reason forces one more turn so Claude
#     actually runs the checklist and desk-log call before really
#     stopping (a Stop hook has no additionalContext equivalent; the
#     forced reason IS the context).
#   - Anything else (e.g. an accidental PreToolUse wiring): errors out
#     loudly instead of silently burning a tick, since this script isn't
#     meant to be wired to any other event.
#
# KNOWN BLIND SPOT (empirically confirmed as of Claude Code 2.1.235, not
# theoretical — re-verify if this stops matching observed behavior after
# an update): this hook has zero visibility into subagent-focused work.
# If the user pane-shifts to
# coach a subagent directly for an extended stretch, no UserPromptSubmit
# or Stop from that subagent ever reaches this script — only the
# orchestrator's own turns do. A background subagent finishing does
# surface as a <task-notification>-prefixed UserPromptSubmit on the
# orchestrator (see the guard below), but that's a report-in, not
# subagent-turn visibility, and it's deliberately excluded from firing or
# from resetting the break-gap clock. There is no known hook-level fix for
# this — self-monitor during long stretches of direct subagent coaching.
#
# Deliberately dumb about *content*: it only tracks elapsed/stretch time
# and packages the signal per-event. Interpreting the signal (timebox
# status, checkpoint cadence, end-of-day thresholds, rabbit-hole check) is
# CLAUDE.md/skill-level policy, not this script's job — see the "Session
# discipline" section of ~/.claude/CLAUDE.md.
#
# Timebox: on first invocation of a session (or any time the stretch clock
# gets reseeded — see break-gap and global-break below), this hook picks a
# deadline for the current stretch and writes it into the state file as a
# 4th field: min(now + TIMEBOX_DEFAULT_SECONDS, next-meeting-start -
# TIMEBOX_MEETING_BUFFER_SECONDS). Once real, it's enforced every
# invocation (bypassing the normal INTERVAL_SECONDS gate) until something
# resets the stretch — no snoozing via a bare "y"/follow-up task; see the
# insist text below.
#
# `insisted` (5th field, reset to 0 only where the stretch itself resets)
# caps how many times a Stop event is allowed to actually BLOCK for a given
# expired-timebox/critical-go-home stretch: once. decision:"block" on Stop
# doesn't pause for a human reply — it forces Claude straight into another
# turn with no user input involved — so blocking on every single Stop while
# expired is not "ask and wait," it's an unconditional, unattended
# re-trigger loop (confirmed live: identical message, turn after turn,
# while the user was away and never a party to any of it). One hard block
# is enough to force the model to actually raise it with the user; after
# that, subsequent Stops while still expired get a non-blocking
# systemMessage instead — visible, but lets the turn really end so a human
# who's AFK can come back and answer in their own time instead of the
# agent being mechanically re-triggered against no one.
#
# Global break axis: log_break (an agent-env MCP tool, not this script)
# writes a single global timestamp to GLOBAL_BREAK_FILE — deliberately
# NOT scoped to one session, because a per-session-only clock is dishonest
# about actual time-at-screen for a user who runs several concurrent
# sessions (worktrees, parallel agents): closing one and opening a fresh
# one would otherwise reset to zero without a real break happening. Any
# session whose stretch predates that global timestamp treats it exactly
# like its own implicit break-gap detection — reseed and re-announce.
#
# Calendar watcher: entirely optional and decoupled from everything above,
# on its own faster cadence (CALENDAR_CHECK_INTERVAL_SECONDS), gated only
# by whether a generically-named `meeting-check.py` exists on PATH. This
# checked-in script deliberately knows nothing about *how* that command
# gets its answer (a personal, git-ignored ~/bin/meeting-check.py talks to
# whatever calendar backend applies) — no company-specific tool names
# belong in a script that ships as part of a shared plugin. Runs are
# throttled by their own state file, independent of the tick's own
# 20-minute interval, so it can surface "meeting starting soon" sooner
# than the main tick would otherwise allow, and fails completely open
# (missing command, timeout, bad output — all silently treated as
# "nothing to report") since a calendar hiccup must never break the rest
# of this hook.
set -euo pipefail
[ -z "${DEBUG:-}" ] || echo "$(date '+%Y-%m-%d %H:%M:%S') invoked pid=$$ session=${CLAUDE_CODE_SESSION_ID:-none}" >> "${HOME}/.claude/hooks/state/discipline-tick/debug.log"

INTERVAL_SECONDS=1200        # 20 minutes (pomodoro) — check-in cadence
BREAK_GAP_SECONDS=1800       # 30 min with no hook invocation = you stepped away
STRETCH_LIMIT_SECONDS=3600   # 60 min continuous = insist on an actual break
MAX_PLAUSIBLE_AGE_SECONDS=604800  # 7 days — anything older is corrupt/stale state, not a long session
CALENDAR_CHECK_INTERVAL_SECONDS=300  # 5 min — independent, faster than the tick's own cadence
CALENDAR_CHECK_CMD="meeting-check.py"  # generic name; personal/company-specific implementation lives outside this repo
TIMEBOX_DEFAULT_SECONDS=2700       # 45 min — default stretch length
TIMEBOX_MEETING_BUFFER_SECONDS=300 # 5 min — buffer before a known next meeting
TIMEBOX_DEFAULT_MINUTES=$((TIMEBOX_DEFAULT_SECONDS / 60))
TIMEBOX_MEETING_BUFFER_MINUTES=$((TIMEBOX_MEETING_BUFFER_SECONDS / 60))
LOCATION_CHECK_INTERVAL_SECONDS=300  # 5 min — SSID lookup is slow-ish, throttle like the calendar watcher
LOCATION_CONFIG="${HOME}/.claude/hooks/state/discipline-tick/location-config.sh"  # machine-local, git-ignored; see INSTALL.md
# HHMM integers (compared against `date +%H%M` forced to base 10, since
# e.g. "0800" would otherwise parse as invalid octal). Confirmed values.
OFFICE_SOFT_HHMM=1600
OFFICE_HARD_HHMM=1630
OFFICE_CRIT_HHMM=1700
HOME_SOFT_HHMM=1730
HOME_HARD_HHMM=1800
HOME_CRIT_HHMM=1830

session_id="${CLAUDE_CODE_SESSION_ID:-}"
[ -n "$session_id" ] || exit 0

hook_input="$(cat 2>/dev/null || true)"
event="$(printf '%s' "$hook_input" | jq -r '.hook_event_name // empty' 2>/dev/null || true)"
transcript_path="$(printf '%s' "$hook_input" | jq -r '.transcript_path // empty' 2>/dev/null || true)"

# Events other than UserPromptSubmit/Stop can't surface plain stdout to
# anyone (see header) — validated up front, before either watcher below
# does any work, since neither is meant to run for any other event.
case "$event" in
    UserPromptSubmit|Stop) ;;
    *) echo >&2 "$0 not set up as hook for $event"; exit 1 ;;
esac

state_dir="${HOME}/.claude/hooks/state/discipline-tick"
mkdir -p "$state_dir"
state_file="${state_dir}/${session_id}.tick"
calendar_state_file="${state_dir}/${session_id}.calendar"
global_break_file="${state_dir}/global-break.state"  # written by the log_break MCP tool, not this script
location_override_file="${state_dir}/location-override.state"  # written by the set_location MCP tool
location_cache_file="${state_dir}/${session_id}.location"

# HOME_SSIDS/OFFICE_SSIDS come from LOCATION_CONFIG if present; declared
# empty here so `${OFFICE_SSIDS[@]}` etc. never trip `set -u` when the
# config is missing or doesn't define one of them.
HOME_SSIDS=()
OFFICE_SSIDS=()
# shellcheck disable=SC1090
[ -f "$LOCATION_CONFIG" ] && source "$LOCATION_CONFIG"

now="$(date +%s)"

is_plausible_ts() {
    case "$1" in
        ''|*[!0-9]*) return 1 ;;
    esac
    [ "$1" -le "$now" ] || return 1
    [ $((now - $1)) -le "$MAX_PLAUSIBLE_AGE_SECONDS" ] || return 1
    return 0
}

# Calendar watcher runs first and independent of everything below: it has
# its own interval, its own state file, and doesn't care whether the main
# tick fires this invocation. `calendar_line`, if set, is either combined
# into the main tick's message (if one also fires this call) or emitted
# on its own via the early-exit helper below.
calendar_line=""
if command -v "$CALENDAR_CHECK_CMD" >/dev/null 2>&1; then
    cal_last_check=0
    if [ -f "$calendar_state_file" ]; then
        cal_last_check_raw="$(sed -n '1p' "$calendar_state_file" 2>/dev/null || true)"
        is_plausible_ts "$cal_last_check_raw" && cal_last_check="$cal_last_check_raw"
    fi
    if [ $((now - cal_last_check)) -ge "$CALENDAR_CHECK_INTERVAL_SECONDS" ]; then
        printf '%s\n' "$now" > "$calendar_state_file"
        meeting_result="$(timeout 8 "$CALENDAR_CHECK_CMD" 2>/dev/null || true)"
        if [ -n "$meeting_result" ]; then
            # meeting-check.py prints one line per fact, not one line total —
            # being in a meeting now AND having another starting soon are
            # both real often enough (back-to-back scheduling) that an
            # if/elif here would silently drop whichever fact lost.
            calendar_facts=()
            while IFS='|' read -r kind subject mins_val clock epoch_val; do
                [ -n "$kind" ] || continue
                case "$kind" in
                    ongoing)
                        calendar_facts+=("You were supposed to be in \"${subject}\" since ${mins_val} minute(s) ago (until ${clock}).")
                        ;;
                    soon)
                        calendar_facts+=("Heads up: \"${subject}\" starts in ${mins_val} minute(s) (at ${clock}).")
                        ;;
                esac
            done <<CALEOF
$meeting_result
CALEOF
            if [ "${#calendar_facts[@]}" -gt 0 ]; then
                calendar_line="$(printf '%s\n' "${calendar_facts[@]}")"
            fi
        fi
    fi
fi

# Fresh, unthrottled calendar query used only at stretch-seed time (session
# start / break reset) to pick the timebox deadline — deliberately separate
# from the throttled watcher above so the one-time timebox decision isn't
# at the mercy of whether the watcher happened to run this same
# invocation. Prints the next "soon" meeting's start epoch, or nothing.
query_next_meeting_soon_epoch() {
    command -v "$CALENDAR_CHECK_CMD" >/dev/null 2>&1 || return 0
    local result kind subject mins_val clock epoch_val
    result="$(timeout 8 "$CALENDAR_CHECK_CMD" 2>/dev/null || true)"
    [ -n "$result" ] || return 0
    while IFS='|' read -r kind subject mins_val clock epoch_val; do
        if [ "$kind" = "soon" ] && [ -n "$epoch_val" ]; then
            printf '%s' "$epoch_val"
            return 0
        fi
    done <<CALEOF
$result
CALEOF
}

# Sets TIMEBOX_END/TIMEBOX_SOURCE (globals, not locals — read by callers)
# and writes the freshly-seeded state file. Called whenever the stretch
# clock restarts: first invocation of a session, break-gap detection, or a
# global-break reset.
seed_stretch_and_timebox() {
    local soon_epoch meeting_bound
    soon_epoch="$(query_next_meeting_soon_epoch)"
    TIMEBOX_END=$((now + TIMEBOX_DEFAULT_SECONDS))
    TIMEBOX_SOURCE="the default ${TIMEBOX_DEFAULT_MINUTES}-minute stretch"
    if [ -n "$soon_epoch" ]; then
        meeting_bound=$((soon_epoch - TIMEBOX_MEETING_BUFFER_SECONDS))
        if [ "$meeting_bound" -lt "$TIMEBOX_END" ]; then
            TIMEBOX_END="$meeting_bound"
            TIMEBOX_SOURCE="${TIMEBOX_MEETING_BUFFER_MINUTES} minutes before your next meeting"
        fi
    fi
    printf '%s\n%s\n%s\n%s\n%s\n' "$now" "$now" "$now" "$TIMEBOX_END" 0 > "$state_file"
}

# Resolves office/home/"" via live WiFi SSID first, manual override
# second. `system_profiler`/`networksetup` need macOS Location Services
# permission to read the real SSID — without it they return the literal
# string "<redacted>" (not an error) or claim "not associated" while
# genuinely connected; see INSTALL.md. Either failure mode is treated as
# "detection inconclusive," falling through to location-override.state
# (set via the set_location MCP tool) — but only if that override is
# still from today (local calendar day): a location assertion is a daily
# fact, unlike the deliberately-not-day-keyed global-break axis above, so
# it must not silently persist into tomorrow if never cleared.
resolve_current_location() {
    local ssid="" s
    if command -v system_profiler >/dev/null 2>&1; then
        ssid="$(timeout 5 system_profiler -json SPAirPortDataType 2>/dev/null \
            | jq -r '.SPAirPortDataType[0].spairport_airport_interfaces[0].spairport_current_network_information._name // empty' 2>/dev/null || true)"
    fi
    case "$ssid" in
        ''|'<redacted>') ssid="" ;;
    esac
    if [ -n "$ssid" ]; then
        for s in "${OFFICE_SSIDS[@]}"; do
            [ "$ssid" = "$s" ] && { printf 'office'; return 0; }
        done
        for s in "${HOME_SSIDS[@]}"; do
            [ "$ssid" = "$s" ] && { printf 'home'; return 0; }
        done
    fi
    if [ -f "$location_override_file" ]; then
        local ov_epoch ov_loc
        ov_epoch="$(sed -n '1p' "$location_override_file" 2>/dev/null || true)"
        ov_loc="$(sed -n '2p' "$location_override_file" 2>/dev/null || true)"
        if is_plausible_ts "$ov_epoch" && [ "$(date -r "$ov_epoch" '+%Y%m%d' 2>/dev/null)" = "$(date '+%Y%m%d')" ]; then
            printf '%s' "$ov_loc"
            return 0
        fi
    fi
    printf ''
}

# Fresh, unthrottled query for the two meeting facts the timebox-expired
# message needs to fold in — deliberately separate from the throttled
# calendar watcher above, for the same reason seed_stretch_and_timebox
# doesn't reuse it: this script is a fresh process per hook invocation, so
# the watcher's calendar_line is only non-empty on the tick where it
# happened to run its 5-min-throttled check, but a timebox-expired message
# can fire on every single tick — it needs its own on-demand read, not a
# value that's usually stale-empty by coincidence of timing.
query_meeting_facts() {
    meeting_soon_subject=""; meeting_soon_mins=""
    meeting_ongoing_subject=""; meeting_ongoing_mins=""
    command -v "$CALENDAR_CHECK_CMD" >/dev/null 2>&1 || return 0
    local result kind subject mins_val clock epoch_val
    result="$(timeout 8 "$CALENDAR_CHECK_CMD" 2>/dev/null || true)"
    [ -n "$result" ] || return 0
    while IFS='|' read -r kind subject mins_val clock epoch_val; do
        case "$kind" in
            soon) meeting_soon_subject="$subject"; meeting_soon_mins="$mins_val" ;;
            ongoing) meeting_ongoing_subject="$subject"; meeting_ongoing_mins="$mins_val" ;;
        esac
    done <<CALEOF
$result
CALEOF
}

# Location watcher: same throttle-by-cache-file shape as the calendar
# watcher, but its own file/cadence since SSID lookup and calendar lookup
# are unrelated costs. current_location/go_home_tier/go_home_critical/
# location_line are consumed later for both the bypass-gate and message
# composition.
current_location=""
loc_cache_valid=0
if [ -f "$location_cache_file" ]; then
    loc_last_check="$(sed -n '1p' "$location_cache_file" 2>/dev/null || true)"
    cached_location="$(sed -n '2p' "$location_cache_file" 2>/dev/null || true)"
    if is_plausible_ts "$loc_last_check" && [ $((now - loc_last_check)) -lt "$LOCATION_CHECK_INTERVAL_SECONDS" ]; then
        loc_cache_valid=1
        current_location="$cached_location"
    fi
fi
if [ "$loc_cache_valid" -ne 1 ]; then
    current_location="$(resolve_current_location)"
    printf '%s\n%s\n' "$now" "$current_location" > "$location_cache_file"
fi

go_home_tier=""
if [ -n "$current_location" ]; then
    now_hhmm=$((10#$(date +%H%M)))
    case "$current_location" in
        office)
            if   [ "$now_hhmm" -ge "$OFFICE_CRIT_HHMM" ]; then go_home_tier="critical"
            elif [ "$now_hhmm" -ge "$OFFICE_HARD_HHMM" ]; then go_home_tier="hard"
            elif [ "$now_hhmm" -ge "$OFFICE_SOFT_HHMM" ]; then go_home_tier="soft"
            fi
            ;;
        home)
            if   [ "$now_hhmm" -ge "$HOME_CRIT_HHMM" ]; then go_home_tier="critical"
            elif [ "$now_hhmm" -ge "$HOME_HARD_HHMM" ]; then go_home_tier="hard"
            elif [ "$now_hhmm" -ge "$HOME_SOFT_HHMM" ]; then go_home_tier="soft"
            fi
            ;;
    esac
fi
go_home_critical=0
[ "$go_home_tier" = "critical" ] && go_home_critical=1

# Soft/hard tiers are message-only (prepended like calendar_line, see
# below) — only "critical" earns bypass-gate + blocking treatment, same
# tier the user confirmed should behave like timebox_expired. Wording
# here is a placeholder pending the user's own draft (they specifically
# asked not to have user-facing nag prose written for them) — see
# go-home-wording.draft.md.
location_line=""
case "$go_home_tier" in
    soft) location_line="[PLACEHOLDER go-home SOFT wording — see go-home-wording.draft.md]" ;;
    hard) location_line="[PLACEHOLDER go-home HARD wording — see go-home-wording.draft.md]" ;;
esac

# Combines seeding + announcement + exit, used by every reseed path so the
# user always hears the new deadline (not just on a genuinely fresh
# session) — "announce that fact" applies equally to a break-triggered
# reset, since that's also the start of a new stretch.
seed_and_exit() {
    seed_stretch_and_timebox
    local tb_clock
    tb_clock="$(date -r "$TIMEBOX_END" '+%H:%M' 2>/dev/null || echo '?')"
    local timebox_msg="Timebox for this stretch: ${TIMEBOX_SOURCE}, ending around ${tb_clock}."
    local combined="$timebox_msg"
    if [ -n "$calendar_line" ]; then
        combined="${calendar_line}

${timebox_msg}"
    fi
    jq -n --arg msg "$combined" '{systemMessage: $msg}'
    exit 0
}

# Any early exit below (main tick not due yet, for whatever reason) still
# needs to surface a pending calendar_line rather than discard it — the
# calendar watcher's whole point is a faster cadence than the tick, so it
# must not get silently swallowed by the tick's own gating.
maybe_emit_calendar_only_and_exit() {
    local combined="$calendar_line"
    if [ -n "$location_line" ]; then
        if [ -n "$combined" ]; then
            combined="${combined}

${location_line}"
        else
            combined="$location_line"
        fi
    fi
    if [ -n "$combined" ]; then
        jq -n --arg msg "$combined" '{systemMessage: $msg}'
    fi
    exit 0
}

# State file is five lines: stretch-start timestamp, last-fire timestamp,
# last-invocation timestamp (updated on every call, fire or not — it's
# purely how we detect a break happened), timebox-end timestamp (a future
# deadline, so NOT validated with is_plausible_ts, which requires <= now —
# just checked for being a plain non-negative integer; 0/unset means "no
# timebox"), insisted flag (0/1 — whether a Stop event has already hard-
# blocked once for the current expired stretch; see the top-of-file note).
# Any shape/schema drift (a stale file from a prior version of this
# script, a partial write, whatever) is treated as absent and reseeded —
# trusting a malformed field is how a bare integer like an old fire-count
# got misread as a Unix epoch and produced a multi-million-minute check-in
# message. A leftover 4-line file from before the insisted field existed
# also falls into this reseed path, which is a convenient side effect: it
# clears any stretch that was stuck hard-blocking every Stop under the old
# logic. is_plausible_ts rejects anything non-numeric, in the future, or
# implausibly old.
state_valid=0
timebox_end=0
insisted=0
if [ -f "$state_file" ] && [ "$(wc -l < "$state_file" 2>/dev/null | tr -d ' ')" = 5 ]; then
    stretch_start="$(sed -n '1p' "$state_file" 2>/dev/null)"
    last_fire="$(sed -n '2p' "$state_file" 2>/dev/null)"
    last_invocation="$(sed -n '3p' "$state_file" 2>/dev/null)"
    timebox_end_raw="$(sed -n '4p' "$state_file" 2>/dev/null)"
    insisted_raw="$(sed -n '5p' "$state_file" 2>/dev/null)"
    if is_plausible_ts "$stretch_start" && is_plausible_ts "$last_fire" && is_plausible_ts "$last_invocation"; then
        state_valid=1
        case "$timebox_end_raw" in
            ''|*[!0-9]*) timebox_end=0 ;;
            *) timebox_end="$timebox_end_raw" ;;
        esac
        case "$insisted_raw" in
            1) insisted=1 ;;
            *) insisted=0 ;;
        esac
    fi
fi

if [ "$state_valid" -ne 1 ]; then
    # Missing, malformed, or implausible — this is "first invocation of the
    # session" as far as this hook can tell. Seed a fresh stretch + timebox
    # and announce it; don't fire the check-in nag immediately.
    seed_and_exit
fi

# A real gap since the last invocation usually means a break happened —
# but a meeting produces the identical gap pattern (no hook invocations)
# while providing none of the restoration, so it must not be credited as
# one. If the gap overlaps a real calendar meeting, only the check-in
# cadence resets (no retroactive nag for time already spent in the
# meeting); stretch_start and timebox_end carry straight through
# unchanged, since a meeting is continued cognitive load, not a break —
# if the timebox already expired mid-meeting, it should still read as
# expired the moment you're back. Fails open to "credit it as a break" if
# the calendar command is missing or errors, same as the rest of this
# script's calendar handling.
gap=$((now - last_invocation))
if [ "$gap" -ge "$BREAK_GAP_SECONDS" ]; then
    meeting_covered=0
    if command -v "$CALENDAR_CHECK_CMD" >/dev/null 2>&1; then
        covered_result="$(timeout 8 "$CALENDAR_CHECK_CMD" --since "$last_invocation" 2>/dev/null || true)"
        case "$covered_result" in
            covered\|*) meeting_covered=1 ;;
        esac
    fi
    if [ "$meeting_covered" -eq 1 ]; then
        printf '%s\n%s\n%s\n%s\n%s\n' "$stretch_start" "$now" "$now" "$timebox_end" "$insisted" > "$state_file"
        maybe_emit_calendar_only_and_exit
    fi
    seed_and_exit
fi

# Global break axis: log_break (the agent-env MCP tool) can be called from
# ANY session, not just this one. If that assertion landed after this
# session's current stretch began, honor it exactly like implicit
# break-gap detection above — the user's explicit word is at least as
# trustworthy as an inferred silence gap. Checked before the
# task-notification skip below: a deliberate log_break call should reset
# things even mid-subagent-report, unlike the ambiguous silent-gap heuristic.
if [ -f "$global_break_file" ]; then
    global_break_raw="$(sed -n '1p' "$global_break_file" 2>/dev/null || true)"
    if is_plausible_ts "$global_break_raw" && [ "$global_break_raw" -gt "$stretch_start" ]; then
        seed_and_exit
    fi
fi

# A UserPromptSubmit whose prompt is a synthetic <task-notification> (a
# background subagent reporting in) is not a real "before you embark" or
# "returning the ball to the user" moment — it lands mid-thought, where the
# user is unlikely to notice the systemMessage and Claude is mid-flow and
# likely to rubber-stamp the checklist rather than actually run it. Defer
# the actual check-in to the next genuine UserPromptSubmit or Stop instead
# of firing here. Deliberately leave the state file untouched rather than
# refreshing last_invocation: a fleet of subagents can keep reporting in
# for hours while the user is genuinely away, and touching the clock here
# would mask exactly the break-gap this hook exists to detect. A pending
# calendar_line still gets surfaced, though — a meeting notice is worth
# showing even mid-subagent-report.
if [ "$event" = "UserPromptSubmit" ]; then
    prompt_text="$(printf '%s' "$hook_input" | jq -r '.prompt // empty' 2>/dev/null || true)"
    case "$prompt_text" in
        '<task-notification>'*) maybe_emit_calendar_only_and_exit ;;
    esac
fi

elapsed=$((now - last_fire))

# A live timebox breach bypasses the normal 20-minute gate entirely — this
# hook still runs on every single invocation from here on, not just once,
# since last_fire gets bumped to $now below regardless (timebox_end itself
# never moves until a reseed). That part is deliberate: the whole point
# raised was that a passive nag gets silently worked past, so the check-in
# keeps firing instead of going quiet for 20 minutes. What no longer
# follows from "keeps firing" is "keeps hard-blocking Stop" — see the
# `insisted` gate below in the Stop case, and the top-of-file note, for why
# unconditional blocking here used to produce a runaway loop. Persisting
# until something actually resets the stretch (log_break, a real gap, a
# new session) is the fix for the passive-nag problem — see the insist
# text below for what "resets" is allowed to mean.
timebox_expired=0
if [ "$timebox_end" -gt 0 ] && [ "$now" -ge "$timebox_end" ]; then
    timebox_expired=1
fi

# Both bypass conditions share the one `insisted` flag — "has a Stop event
# already hard-blocked once this stretch for being over some hard line,"
# regardless of which line. See the Stop case below.
bypass_tier=0
if [ "$timebox_expired" -eq 1 ] || [ "$go_home_critical" -eq 1 ]; then
    bypass_tier=1
fi

if [ "$elapsed" -lt "$INTERVAL_SECONDS" ] && [ "$timebox_expired" -ne 1 ] && [ "$go_home_critical" -ne 1 ]; then
    printf '%s\n%s\n%s\n%s\n%s\n' "$stretch_start" "$last_fire" "$now" "$timebox_end" "$insisted" > "$state_file"
    maybe_emit_calendar_only_and_exit
fi

printf '%s\n%s\n%s\n%s\n%s\n' "$stretch_start" "$now" "$now" "$timebox_end" "$insisted" > "$state_file"
mins=$((elapsed / 60))
stretch_mins=$(( (now - stretch_start) / 60 ))

# Transcript file size is a crude proxy for context size (no direct token
# count is available to a hook) — good enough to flag "large," not precise.
context_note=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    size_bytes="$(wc -c < "$transcript_path" 2>/dev/null | tr -d ' ')"
    case "$size_bytes" in
        ''|*[!0-9]*) size_bytes=0 ;;
    esac
    if [ "$size_bytes" -ge 2000000 ]; then
        context_note=" Transcript is already large (~$((size_bytes / 1000))KB) — write one now (./CLAUDE.local.md for a quick note, or ~/desk/checkpoints/YYYYMMDD/<slug>.md + desk-log for anything substantial) in case a compaction event loses detail before you get to it."
    fi
fi

# Larger instruction first, checklist second — so Claude knows *why* it's
# reading the list before it reads it, not after. Quasi-XML <ol>/<li>
# (not markdown bullets) mainly for the human's benefit: the more
# code-like the block looks, the more reflexively skippable it is.
agent_directive="Run this check, surface it to the user aloud, then desk-log a one-line status. Do the actual checks first — don't rubber-stamp the log line."
checklist_items="<ol><li>Timebox on track (soft-timebox skill)?</li><li>End-of-day thresholds apply (end-of-day-awareness skill)?</li><li>Checkpoint due (load local-notes-and-checkpoints skill for format)?${context_note}</li><li>Still matching stated priorities, or drifted into a rabbit hole?</li></ol>"

# Four tiers, checked in priority order. `user_message` is genuinely
# user-facing prose — `insist`, by contrast, is a Claude-behavior
# directive, so it lives in the agent-only block below, not here.
if [ "$timebox_expired" -eq 1 ]; then
    # Single template, one contextual addendum chosen by priority — not a
    # kitchen-sink of every true fact at once. Deliberately drops
    # lower-priority facts when a higher one wins (e.g. a soft go-home
    # warning goes unmentioned if a meeting is starting soon) rather than
    # stacking everything into one message every time. User-authored
    # structure — see timebox-expired-wording.draft.md for the design
    # rationale if this needs revisiting.
    tb_clock="$(date -r "$timebox_end" '+%H:%M' 2>/dev/null || echo '?')"
    mins_since_expiry=$(( (now - timebox_end) / 60 ))
    query_meeting_facts

    header="Hello John, this is your conscience. Your timebox expired at ${tb_clock}, ${mins_since_expiry} minute(s) ago."

    break_due=0
    [ "$stretch_mins" -ge $((STRETCH_LIMIT_SECONDS / 60)) ] && break_due=1

    if [ "$break_due" -eq 1 ] && [ -z "$meeting_soon_subject" ] && [ -z "$meeting_ongoing_subject" ]; then
        addendum="Plus it's been ${stretch_mins} minute(s) since your last break. Stand up and walk around."
    elif [ -n "$meeting_soon_subject" ]; then
        addendum="Plus your meeting \"${meeting_soon_subject}\" is in ${meeting_soon_mins} minute(s). Take a minute to prepare; or, tell the agent you're not going, and take a break."
    elif [ -n "$meeting_ongoing_subject" ]; then
        addendum="Plus you are late for a meeting, \"${meeting_ongoing_subject}\". Go; or, tell the agent you're not going and take a break."
    elif [ -n "$go_home_tier" ]; then
        if [ "$go_home_tier" = "soft" ]; then
            addendum="Look at the clock, it may be time to pack up and head home."
        else
            addendum="Look at the clock, it is time to pack up and head home."
        fi
    else
        addendum="Please take a break. Stand up and walk around for a minute."
    fi

    user_message="${header}

${addendum}"
    insist="The timebox for this stretch expired at ${tb_clock} and has not been reset. Do not accept a bare acknowledgment, a quick \"y\"/\"go ahead\", or a follow-up task as satisfying this. Either the user calls log_break via the agent-env MCP tool (confirming they're actually stepping away), or they explicitly and specifically state they're choosing to continue past their own stated timebox and why. Ask directly and wait for one of those two things before proceeding."
elif [ "$go_home_critical" -eq 1 ]; then
    # Fires independently of timebox status — the critical go-home
    # threshold matters even mid-stretch. Placeholder pending the user's
    # own wording (see go-home-wording.draft.md); mechanics (bypass gate,
    # blocking insist) are real and tested.
    user_message="[PLACEHOLDER go-home CRITICAL wording, timebox not (yet) expired — see go-home-wording.draft.md]"
    insist="The critical go-home threshold has passed while at ${current_location:-an unknown location} (this is independent of the per-stretch timebox, which has not separately expired). Do not accept a bare acknowledgment or a follow-up task as satisfying this — ask directly whether they're wrapping up now or explicitly continuing and why, same standard as the timebox-expired case."
elif [ "$stretch_mins" -ge $((STRETCH_LIMIT_SECONDS / 60)) ]; then
    user_message="John. You've been at this continuously for **${stretch_mins} minutes**. You need a mental check-in.

Drink some water. Check your messages. At the very least, stand up and look away from the screen for 30 seconds.

And, for the love of god, please consider taking a break."
    insist="Do not start the user's next request until they've explicitly acknowledged taking a real break (or explicitly say they want to keep going right now) — ask directly, don't treat a follow-up task as an answer."
else
    user_message="Take a second. Still where you meant to be, or is this a rabbit hole? Stand up and look around for a moment."
    insist=""
fi

# Calendar/location facts lead the message on the two lower tiers, same as
# before — but not on the timebox-expired tier, which already folds the
# relevant one of these facts into its own addendum above; showing it
# again via a bare prepend would just duplicate it (or, worse, show a
# lower-priority fact the template deliberately chose not to surface).
if [ "$timebox_expired" -ne 1 ]; then
    if [ -n "$location_line" ]; then
        user_message="${location_line}

${user_message}"
    fi
    if [ -n "$calendar_line" ]; then
        user_message="${calendar_line}

${user_message}"
    fi
fi

# Explicit "this is a directive, not background flavor text" cue —
# injected/tagged context is easy to under-weight relative to something
# the user just said directly; naming the audience by name pushes back
# on that.
agent_only_flag="Claude (or agent), you must follow the agent-only prompt that follows."
agent_only="${mins}m since last check-in (~${stretch_mins}m this stretch). ${agent_directive} ${checklist_items}${insist:+ ${insist}}"

case "$event" in
    Stop)
        if [ "$bypass_tier" -eq 1 ] && [ "$insisted" -eq 1 ]; then
            # Already hard-blocked once this stretch for a bypass condition
            # (expired timebox or critical go-home). decision:"block" does
            # not pause for a human reply — it just forces Claude into
            # another turn with no user involved — so blocking again here
            # would be the unattended re-trigger loop described at the top
            # of this file, not a real "wait for the user." One hard block
            # already did its job of forcing this in front of the model;
            # a plain, non-blocking notice keeps it visible on every
            # subsequent Stop without preventing the turn from actually
            # ending, so a human who's away can come back and answer
            # whenever, instead of the agent spinning against no one.
            jq -n --arg msg "$user_message" '{systemMessage: $msg}'
        else
            if [ "$bypass_tier" -eq 1 ]; then
                printf '%s\n%s\n%s\n%s\n%s\n' "$stretch_start" "$now" "$now" "$timebox_end" 1 > "$state_file"
            fi
            # `reason` is unavoidably shown to the user verbatim (as a "Stop
            # hook blocking error" box) — there's no hidden-channel equivalent
            # of UserPromptSubmit's additionalContext for Stop. Leading blank
            # lines keep the message from visually colliding with the harness's
            # own "Stop hook blocking error from command: ..." preamble line.
            reason=$'\n\n'"${user_message}

${agent_only_flag}

<agent-only>${agent_only}</agent-only>"
            user_msg="[discipline-tick] check-in (${mins}m since last, ~${stretch_mins}m this stretch) — see above."
            jq -n --arg reason "$reason" --arg msg "$user_msg" '{decision: "block", reason: $reason, systemMessage: $msg}'
        fi
        ;;
    UserPromptSubmit)
        # additionalContext is already 100% Claude-directed (never shown
        # to the user), so the flag is prepended inline rather than as a
        # separate visible line — same reinforcement, no user-facing text.
        context="${agent_only_flag} ${agent_only}"
        jq -n --arg ctx "$context" --arg msg "$user_message" \
            '{systemMessage: $msg, hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $ctx}}'
        ;;
esac
