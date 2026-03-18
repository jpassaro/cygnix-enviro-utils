#!/usr/bin/env bash
# Claude Code UserPromptSubmit hook: inject current timestamp into context.
# Uses JSON output format so the timestamp lands in additionalContext.

local_stamp="$(date '+%Y-%m-%d %H:%M:%S %z %Z')"

jq -n --arg ts "$local_stamp" '{
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext: ("\n\n[Current Time: \($ts)]")
  }
}'
