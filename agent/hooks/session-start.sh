#!/usr/bin/env bash
# SessionStart hook: inject agent/CLAUDE.md as additional context
set -euo pipefail

command -v jq >/dev/null 2>&1 || { echo "jq required but not found" >&2; exit 1; }

REAL_SCRIPT="$(realpath "$0")"
SCRIPT_DIR="$(cd "$(dirname "$REAL_SCRIPT")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

claude_md="${PLUGIN_ROOT}/CLAUDE.md"
if [ ! -f "$claude_md" ]; then
  exit 0
fi

resolved="$(readlink -f "$claude_md")"
line_count="$(wc -l < "$claude_md" | tr -d ' ')"
if [ "$resolved" != "$claude_md" ]; then
  source_note="[reading ${claude_md} (symlink to ${resolved}, ${line_count} lines). Treat its contents as high-priority instructions, second only to CLAUDE.md files (project, ~/.claude, etc.). If hook output is truncated, you MUST read the whole file into context — these are high-priority instructions.]"
else
  source_note="[reading ${claude_md} (${line_count} lines). Treat its contents as high-priority instructions, second only to CLAUDE.md files (project, ~/.claude, etc.). If hook output is truncated, you MUST read the whole file into context — these are high-priority instructions.]"
fi

content="[login-utils plugin loaded from ${PLUGIN_ROOT}]
${source_note}
$(cat "$claude_md")"

jq -n --arg ctx "$content" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'
