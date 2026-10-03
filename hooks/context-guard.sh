#!/usr/bin/env bash
# Context guard: a PostToolUse hook that tells the agent how full its own
# context window is, once at each threshold.
#
# It reads token usage from the session transcript, so it works in headless
# `claude -p` runs (where no statusline exists to report it).
#
# Inside a forge loop iteration (FORGE_LOOP=1) the message is an instruction:
# checkpoint to the state file and end, because a fresh context is waiting.
# In an interactive session it is advice only; the human decides.
#
# It never blocks a tool call and exits 0 on any error.

WARN="${FORGE_CTX_WARN:-100000}"       # tokens: start wrapping up
CRITICAL="${FORGE_CTX_CRITICAL:-140000}" # tokens: checkpoint now

command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)" || exit 0
transcript="$(jq -r '.transcript_path // empty' <<<"$input" 2>/dev/null)"
session="$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)"
[[ -n "$transcript" && -f "$transcript" && "$session" =~ ^[A-Za-z0-9_-]+$ ]] || exit 0

# Context in use = what the latest main-thread request sent to the model.
used="$(tail -n 60 "$transcript" 2>/dev/null | jq -rs '
  [ .[] | select(.type == "assistant" and (.isSidechain | not) and .message.usage != null) | .message.usage ]
  | last // empty
  | ((.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0))' 2>/dev/null)"
[[ "$used" =~ ^[0-9]+$ ]] || exit 0

marker="${TMPDIR:-/tmp}/forge-ctx-$session"
if (( used < WARN )); then rm -f "$marker"; exit 0; fi   # e.g. after a compaction

level=warn; (( used >= CRITICAL )) && level=critical
[[ "$(cat "$marker" 2>/dev/null)" == "$level" || "$(cat "$marker" 2>/dev/null)" == critical ]] && exit 0
printf '%s' "$level" > "$marker"

k=$(( used / 1000 ))
if [[ -n "${FORGE_LOOP:-}" ]]; then
  state="${FORGE_STATE_FILE:-the slice state file}"
  if [[ "$level" == critical ]]; then
    msg="CONTEXT CRITICAL (${k}k tokens). Checkpoint now: bring any increment in flight to a committable state or revert it, commit, update $state (criteria, progress log, a specific Next action), and end this iteration. A fresh context continues from the state file."
  else
    msg="CONTEXT WARNING (${k}k tokens). Finish the increment in hand, commit it, update $state, and end this iteration instead of starting another increment. A fresh context continues from the state file."
  fi
else
  if [[ "$level" == critical ]]; then
    msg="Context is at ${k}k tokens, past the range where reasoning stays sharp. Tell the user, and suggest picking a move from the phase-boundary tree (/forge:help) at the next natural stopping point. The decision is theirs."
  else
    msg="Context is at ${k}k tokens. Avoid starting large new explorations in this session; delegate reading to subagents where you can."
  fi
fi

jq -n --arg m "$msg" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $m}}'
exit 0
