#!/usr/bin/env bash
# PreToolUse hook (Bash). Inside a forge agent call (FORGE_JOURNAL is set), it
# writes each command to that call's journal before the command runs. The
# journal is the part of the cleanup registry that does not depend on the
# agent: whatever the agent forgot to record, and however the call ends, the
# commands it ran are on disk. The cleanup pass reads it against the agent's
# own intent records.
#
# It is a write-ahead log, so a command that cannot be journaled does not run.
# Outside a forge agent call it does nothing.

[[ -n "${FORGE_JOURNAL:-}" ]] || exit 0

cmd="$(jq -r '.tool_input.command // empty' 2>/dev/null)" || {
  echo "forge: could not read the command to journal it (is jq installed?); the command was not run" >&2; exit 2
}
[[ -n "$cmd" ]] || exit 0

{ printf '%s\t%s\n' "$(date '+%F %T')" "${cmd//$'\n'/ \\n }" >> "$FORGE_JOURNAL"; } 2>/dev/null || {
  echo "forge: could not write the command journal at $FORGE_JOURNAL; the command was not run" >&2; exit 2
}
exit 0
