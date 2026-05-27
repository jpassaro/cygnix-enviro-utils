#!/usr/bin/env bash
# SessionStart hook: inject agent/CLAUDE.md as additional context
set -euo pipefail

command -v jq >/dev/null 2>&1 || { echo "jq required but not found" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

claude_md="${PLUGIN_ROOT}/CLAUDE.md"
if [ ! -f "$claude_md" ]; then
  exit 0
fi

content="[login-utils plugin loaded from ${PLUGIN_ROOT}]
[reading ${claude_md}. If hook output is truncated, you MUST read the whole file into context and treat its contents as high-priority instructions.]
$(cat "$claude_md")"

jq -n --arg ctx "$content" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'
