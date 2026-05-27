#!/usr/bin/env bash
# Claude Code UserPromptSubmit hook: inject dynamic context.
# Uses JSON output format so values land in additionalContext.

local_stamp="$(date '+%Y-%m-%d %H:%M:%S %z %Z')"
cwd="$(pwd)"

printf -v ctx '\n\n[Current Time: %s]\n[CWD: %s]' "$local_stamp" "$cwd"

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
if [ -n "$branch" ]; then
  printf -v ctx '%s\n[Branch: %s]' "$ctx" "$branch"
fi

jq -n --arg ctx "$ctx" '{
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext: $ctx
  }
}'
