#!/usr/bin/env bash
# Claude Code status line v2
# Layout: time │ <pct%> tokens/max │ location (branch*+%=) │ $cost dur (api dur) │ aws⏱TTL │ Model
#
# Progressive compaction as COLUMNS shrinks:
#   1. Drop wall-clock duration
#   2. Drop api duration
#   3. Drop context denominator
#   4. Drop context raw token count
#   5. Shed sections: model → PR → aws → git symbols
#
# Configurable segments via STATUSLINE_ELEMENTS env var (comma-separated):
#   Available: time, context, git, cost, duration, aws, model, pr
#   When unset or empty, all segments are shown.

# --- Helpers ----------------------------------------------------------------

format_tokens() {
    local t=$1
    if [ "$t" -ge 1000000 ]; then
        echo "$(((t + 500000) / 1000000))M"
    elif [ "$t" -ge 1000 ]; then
        echo "$(((t + 500) / 1000))k"
    else
        echo "$t"
    fi
}

format_duration() {
    local s="$(($1 / 1000))"
    if [ "$s" -lt 60 ]; then
        echo "${s}s"
    elif [ "$s" -lt 3600 ]; then
        echo "$((s / 60))m"
    else
        local h=$((s / 3600)) m=$(((s % 3600) / 60))
        [ "$m" -gt 0 ] && echo "${h}h${m}m" || echo "${h}h"
    fi
}

sanitize_model_name() {
    local raw="$1"
    case "$raw" in
        Opus*|Sonnet*|Haiku*|Claude\ *) echo "$raw"; return ;;
    esac
    local clean="$raw"
    clean="${clean#global.}"
    clean="${clean#anthropic.}"
    clean="${clean#claude-}"
    IFS='-' read -ra parts <<< "$clean"
    local family="${parts[0]}"
    local version=""
    for ((i=1; i<${#parts[@]}; i++)); do
        local p="${parts[$i]}"
        [[ "$p" =~ ^[0-9]{8} ]] || [[ "$p" =~ ^v[0-9] ]] && break
        if [[ "$p" =~ ^[0-9]{1,2}$ ]]; then
            version="${version:+$version.}$p"
        fi
    done
    family="$(echo "${family:0:1}" | tr '[:lower:]' '[:upper:]')${family:1}"
    echo "${family}${version:+ $version}"
}

segment_enabled() {
    local name="$1"
    if [ -z "${STATUSLINE_ELEMENTS:-}" ]; then
        return 0
    fi
    case ",$STATUSLINE_ELEMENTS," in
        *",$name,"*) return 0 ;;
        *)           return 1 ;;
    esac
}

# --- Parse JSON input -------------------------------------------------------

input="$(cat)"

RAW_MODEL="$(echo "$input" | jq -r '.model.display_name // "Claude"')"
MODEL_DISPLAY="$(sanitize_model_name "$RAW_MODEL")"

TOTAL_COST="$(echo "$input" | jq -r '.cost.total_cost_usd // 0')"
TOTAL_DURATION_MS="$(echo "$input" | jq -r '.cost.total_duration_ms // 0')"
API_DURATION_MS="$(echo "$input" | jq -r '.cost.total_api_duration_ms // 0')"

FAST_MODE="$(echo "$input" | jq -r '.fast_mode // false')"
SESSION_ID="$(echo "$input" | jq -r '.session_id // ""')"
TRANSCRIPT_PATH="$(echo "$input" | jq -r '.transcript_path // ""')"
ADDED_DIRS="$(echo "$input" | jq -r '.workspace.added_dirs | length // 0')"

# Turn count from transcript
TURNS=0
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    TURNS="$(grep -c '"type":"user"' "$TRANSCRIPT_PATH" 2>/dev/null)"
    [[ "$((TURNS))" -eq "$TURNS" ]] 2>/dev/null || TURNS=0
fi

# --- Context window ---------------------------------------------------------

CONTEXT_SIZE="$(echo "$input" | jq -r '.context_window.context_window_size // 200000')"
USED_PCT_RAW="$(echo "$input" | jq -r '.context_window.used_percentage // null')"

if [ "$USED_PCT_RAW" != "null" ]; then
    CTX_PERCENT="$(echo "$USED_PCT_RAW" | cut -d. -f1)"
    CURRENT_USAGE="$(echo "$input" | jq -r '.context_window.current_usage // null')"
    if [ "$CURRENT_USAGE" != "null" ]; then
        CURRENT_INPUT="$(echo "$CURRENT_USAGE" | jq -r '.input_tokens // 0')"
        CACHE_CREATION="$(echo "$CURRENT_USAGE" | jq -r '.cache_creation_input_tokens // 0')"
        CACHE_READ="$(echo "$CURRENT_USAGE" | jq -r '.cache_read_input_tokens // 0')"
        CURRENT_TOKENS=$((CURRENT_INPUT + CACHE_CREATION + CACHE_READ))
    else
        CURRENT_TOKENS=$((CTX_PERCENT * CONTEXT_SIZE / 100))
    fi
else
    CURRENT_USAGE="$(echo "$input" | jq -r '.context_window.current_usage // null')"
    if [ "$CURRENT_USAGE" != "null" ]; then
        CURRENT_INPUT="$(echo "$CURRENT_USAGE" | jq -r '.input_tokens // 0')"
        CACHE_CREATION="$(echo "$CURRENT_USAGE" | jq -r '.cache_creation_input_tokens // 0')"
        CACHE_READ="$(echo "$CURRENT_USAGE" | jq -r '.cache_read_input_tokens // 0')"
        CURRENT_TOKENS=$((CURRENT_INPUT + CACHE_CREATION + CACHE_READ))
    else
        CURRENT_TOKENS=0
    fi
    if [ "$CONTEXT_SIZE" -gt 0 ] 2>/dev/null; then
        CTX_PERCENT=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
    else
        CTX_PERCENT=0
    fi
fi

CURRENT_DISPLAY="$(format_tokens "$CURRENT_TOKENS")"
CONTEXT_SIZE_DISPLAY="$(format_tokens "$CONTEXT_SIZE")"

# --- AWS credential TTL -----------------------------------------------------

AWS_TTL_DISPLAY=""
AWS_CREDS_FILE="${HOME}/.aws/credentials"
AWS_PROFILE_NAME="twdc-bedrock-central"

if [ -f "$AWS_CREDS_FILE" ]; then
    EXPIRATION="$(awk -v profile="[$AWS_PROFILE_NAME]" '
        $0 == profile { found=1; next }
        /^\[/ { found=0 }
        found && /awsmyid_session_expiration/ { gsub(/[^0-9]/, "", $NF); print $NF }
    ' "$AWS_CREDS_FILE" 2>/dev/null)"

    if [ -n "$EXPIRATION" ] && [ "$EXPIRATION" -gt 0 ] 2>/dev/null; then
        NOW_EPOCH="$(date +%s)"
        REMAINING=$((EXPIRATION - NOW_EPOCH))
        if [ "$REMAINING" -le 0 ]; then
            AWS_TTL_DISPLAY="aws⏱EXPIRED"
        elif [ "$REMAINING" -lt 60 ]; then
            AWS_TTL_DISPLAY="aws⏱${REMAINING}s"
        elif [ "$REMAINING" -lt 3600 ]; then
            AWS_TTL_DISPLAY="aws⏱$((REMAINING / 60))m"
        else
            local_h=$((REMAINING / 3600))
            local_m=$(((REMAINING % 3600) / 60))
            if [ "$local_m" -gt 0 ]; then
                AWS_TTL_DISPLAY="aws⏱${local_h}h${local_m}m"
            else
                AWS_TTL_DISPLAY="aws⏱${local_h}h"
            fi
        fi
    fi
fi

# --- Git info (cached) ------------------------------------------------------

GIT_CACHE_FILE="/tmp/.claude-statusline-git-$(pwd | cksum | cut -d' ' -f1)"
GIT_CACHE_TTL=5

refresh_git_cache() {
    local now
    now="$(date +%s)"
    if [ -f "$GIT_CACHE_FILE" ]; then
        local cached_time
        cached_time="$(head -1 "$GIT_CACHE_FILE")"
        if [ $((now - cached_time)) -lt "$GIT_CACHE_TTL" ]; then
            return 0
        fi
    fi

    local branch repo_toplevel
    branch="$(git branch --show-current 2>/dev/null || echo "detached")"
    repo_toplevel="$(git rev-parse --show-toplevel 2>/dev/null)"

    # Git status symbols
    local dirty="" staged="" untracked="" upstream=""
    git diff --no-ext-diff --quiet 2>/dev/null || dirty="*"
    git diff --no-ext-diff --cached --quiet 2>/dev/null || staged="+"
    if git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*' >/dev/null 2>&1; then
        untracked="%"
    fi

    # Upstream comparison
    local counts
    counts="$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)"
    if [ -n "$counts" ]; then
        local ahead behind
        ahead="$(echo "$counts" | cut -f1)"
        behind="$(echo "$counts" | cut -f2)"
        if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
            upstream="<>"
        elif [ "$ahead" -gt 0 ]; then
            upstream=">"
        elif [ "$behind" -gt 0 ]; then
            upstream="<"
        else
            upstream="="
        fi
    fi

    # Repo display name: strip ~/code/ if applicable, ~/ otherwise
    local repo_display
    if [ "$repo_toplevel" = "$HOME" ]; then
        repo_display="\$HOME"
    elif [[ "$repo_toplevel" == "$HOME/code/"* ]]; then
        repo_display="${repo_toplevel##"$HOME"/code/}"
    elif [[ "$repo_toplevel" == "$HOME/"* ]]; then
        repo_display="${repo_toplevel##"$HOME"/}"
    else
        repo_display="$repo_toplevel"
    fi

    # Worktree detection
    local is_worktree="" worktree_name=""
    local git_common_dir git_dir
    git_common_dir="$(git rev-parse --git-common-dir 2>/dev/null)"
    git_dir="$(git rev-parse --git-dir 2>/dev/null)"
    if [ "$git_common_dir" != "$git_dir" ] && [ "$git_common_dir" != ".git" ]; then
        is_worktree="yes"
        worktree_name="$(basename "$(pwd)")"
        local main_repo_path
        main_repo_path="$(dirname "$git_common_dir")"
        if [[ "$main_repo_path" == "$HOME/code/"* ]]; then
            repo_display="${main_repo_path##"$HOME"/code/}"
        elif [[ "$main_repo_path" == "$HOME/"* ]]; then
            repo_display="${main_repo_path##"$HOME"/}"
        else
            repo_display="$main_repo_path"
        fi
    fi

    {
        echo "$now"
        echo "$repo_display"
        echo "$branch"
        echo "$dirty$staged$untracked$upstream"
        echo "$is_worktree"
        echo "$worktree_name"
    } > "$GIT_CACHE_FILE"
}

# --- PR cache ---------------------------------------------------------------

PR_CACHE_DIR="/tmp/.claude-statusline-pr"
PR_CACHE_TTL=600  # 10 minutes

get_pr_number() {
    local branch="$1"
    [ -z "$branch" ] && return
    mkdir -p "$PR_CACHE_DIR"
    local cache_file="$PR_CACHE_DIR/$(echo "$branch" | tr '/' '_')"
    local now
    now="$(date +%s)"

    if [ -f "$cache_file" ]; then
        local cached_time cached_pr
        cached_time="$(head -1 "$cache_file")"
        if [ $((now - cached_time)) -lt "$PR_CACHE_TTL" ]; then
            cached_pr="$(sed -n '2p' "$cache_file")"
            echo "$cached_pr"
            return
        fi
    fi

    # Background refresh to avoid blocking statusline
    (
        local pr_num
        pr_num="$(gh pr view --json number -q '.number' 2>/dev/null || echo "")"
        {
            echo "$(date +%s)"
            echo "$pr_num"
        } > "$cache_file"
    ) & disown

    # Return stale value if available
    if [ -f "$cache_file" ]; then
        sed -n '2p' "$cache_file"
    fi
}

# --- Build git segment ------------------------------------------------------

build_git_segment() {
    local repo_display="$1" branch="$2" symbols="$3" is_worktree="$4" worktree_name="$5" show_symbols="$6"

    local location=""
    if [ "$is_worktree" = "yes" ]; then
        location="${repo_display}/.worktrees/${worktree_name}"
        local name_matches=""
        if [ "$worktree_name" = "$branch" ]; then
            name_matches="yes"
        elif [[ "$worktree_name" =~ ^pr-([0-9]+)$ ]]; then
            name_matches="yes"
        fi

        if [ "$name_matches" = "yes" ]; then
            if [ "$show_symbols" = "yes" ]; then
                if [ -n "$symbols" ]; then
                    location="${location} (${symbols})"
                else
                    location="${location} (⋮)"
                fi
            fi
        else
            if [ "$show_symbols" = "yes" ]; then
                location="${location} (${branch}${symbols})"
            else
                location="${location} (${branch})"
            fi
        fi
    else
        if [ "$show_symbols" = "yes" ]; then
            location="${repo_display} (${branch}${symbols})"
        else
            location="${repo_display} (${branch})"
        fi
    fi
    echo "$location"
}

# --- Assemble with compaction -----------------------------------------------

if [ -n "$JP_TTY" ] && [ -c "/dev/$JP_TTY" ]; then
    COLS="$(stty size < "/dev/$JP_TTY" 2>/dev/null | cut -d' ' -f2)"
fi
COLS="${COLS:-${COLUMNS:-120}}"

TIME_DISPLAY="$(date +%H:%M)"
DURATION="$(format_duration "$TOTAL_DURATION_MS")"
API_DURATION="$(format_duration "$API_DURATION_MS")"
COST_DISPLAY="$(printf "\$%.2f" "$TOTAL_COST")"

if git rev-parse --git-dir > /dev/null 2>&1; then
    refresh_git_cache
    {
        read -r _timestamp
        read -r REPO_DISPLAY
        read -r BRANCH
        read -r GIT_SYMBOLS
        read -r IS_WORKTREE
        read -r WORKTREE_NAME
    } < "$GIT_CACHE_FILE"
else
    REPO_DISPLAY="$(basename "$(pwd)")"
    BRANCH=""
    GIT_SYMBOLS=""
    IS_WORKTREE=""
    WORKTREE_NAME=""
fi

# PR number
PR_DISPLAY=""
if segment_enabled pr && [ -n "$BRANCH" ]; then
    PR_NUM="$(get_pr_number "$BRANCH")"
    [ -n "$PR_NUM" ] && PR_DISPLAY="#${PR_NUM}"
fi

assemble_line() {
    local level="$1"
    local parts=()

    # Time (always shown)
    segment_enabled time && parts+=("$TIME_DISPLAY")

    # Context window
    if segment_enabled context; then
        if [ "$level" -ge 4 ]; then
            parts+=("<${CTX_PERCENT}%>")
        elif [ "$level" -ge 3 ]; then
            parts+=("<${CTX_PERCENT}%> ${CURRENT_DISPLAY}")
        else
            parts+=("<${CTX_PERCENT}%> ${CURRENT_DISPLAY}/${CONTEXT_SIZE_DISPLAY}")
        fi
    fi

    # Git/location
    if segment_enabled git; then
        local show_sym="yes"
        [ "$level" -ge 8 ] && show_sym="no"
        if [ -n "$BRANCH" ]; then
            parts+=("$(build_git_segment "$REPO_DISPLAY" "$BRANCH" "$GIT_SYMBOLS" "$IS_WORKTREE" "$WORKTREE_NAME" "$show_sym")")
        else
            parts+=("$REPO_DISPLAY")
        fi
    fi

    # PR (shed at level 6)
    if [ "$level" -lt 6 ] && [ -n "$PR_DISPLAY" ]; then
        parts+=("$PR_DISPLAY")
    fi

    # Cost + duration
    if segment_enabled cost || segment_enabled duration; then
        local cd_part=""
        if segment_enabled cost; then
            cd_part="$COST_DISPLAY"
        fi
        if segment_enabled duration; then
            if [ "$level" -lt 1 ]; then
                if [ -n "$cd_part" ]; then
                    cd_part="$cd_part $DURATION"
                else
                    cd_part="$DURATION"
                fi
                if [ "$API_DURATION_MS" -gt 0 ] 2>/dev/null; then
                    cd_part="$cd_part (api $API_DURATION)"
                fi
            elif [ "$level" -lt 2 ]; then
                if [ "$API_DURATION_MS" -gt 0 ] 2>/dev/null; then
                    cd_part="${cd_part:+$cd_part }(api $API_DURATION)"
                fi
            fi
        fi
        [ -n "$cd_part" ] && parts+=("$cd_part")
    fi

    # AWS (shed at level 7)
    if [ "$level" -lt 7 ] && segment_enabled aws && [ -n "$AWS_TTL_DISPLAY" ]; then
        parts+=("$AWS_TTL_DISPLAY")
    fi

    # Session ID (shed at level 5)
    if [ "$level" -lt 5 ] && [ -n "$SESSION_ID" ]; then
        parts+=("$SESSION_ID")
    fi

    # Turns (compact at level 3, shed at level 6)
    if [ "$level" -lt 6 ] && [ "$TURNS" -gt 0 ]; then
        if [ "$level" -ge 3 ]; then
            parts+=("t:${TURNS}")
        else
            parts+=("turns:${TURNS}")
        fi
    fi

    # Added dirs (shed at level 6)
    if [ "$level" -lt 6 ] && [ "$ADDED_DIRS" -gt 0 ] 2>/dev/null; then
        parts+=("+${ADDED_DIRS}dirs")
    fi

    # Model + fast mode (shed at level 5)
    if [ "$level" -lt 5 ] && segment_enabled model; then
        local model_seg="$MODEL_DISPLAY"
        if [ "$FAST_MODE" = "true" ]; then
            model_seg="⚡${model_seg}"
        fi
        parts+=("$model_seg")
    fi

    # Join with │
    local output=""
    for seg in "${parts[@]}"; do
        if [ -z "$output" ]; then
            output="$seg"
        else
            output="$output │ $seg"
        fi
    done
    echo "$output"
}

# Try each compaction level until it fits
RESULT=""
for level in 0 1 2 3 4 5 6 7 8; do
    candidate="$(assemble_line "$level")"
    plain="${candidate//[$'\033']\[[0-9;]*m/}"
    if [ "${#plain}" -le "$COLS" ]; then
        RESULT="$candidate"
        break
    fi
done

[ -z "$RESULT" ] && RESULT="$(assemble_line 8)"

echo "$RESULT"
