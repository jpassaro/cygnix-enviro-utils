#!/usr/bin/env bash
# Gemini CLI hook: Inject current timestamp into the prompt context.
# Receives JSON on stdin, outputs JSON on stdout.

input="$(cat)"
event_name="$(echo "$input" | jq -r '.hook_event_name')"
local_stamp="$(date '+%Y-%m-%d %H:%M:%S %z %Z')"

jq -n --arg event "$event_name" --arg local "$local_stamp" \
  '{hookSpecificOutput: {hookEventName: $event, additionalContext: ("\n\n[Current Time: \($local)]")}}'
