#!/usr/bin/env bash
# Block file edits outside the project directory.
path="$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')" \
  || { echo "Blocked: cannot read the tool input (is jq installed?)." >&2; exit 2; }
[[ -z "$path" ]] && exit 0
real="$(realpath -m -- "$path")"
root="$(realpath -- "$CLAUDE_PROJECT_DIR")"
[[ -n "$root" ]] || { echo "Blocked: cannot resolve the project directory." >&2; exit 2; }
case "$real" in
  "$root"/*) exit 0 ;;
  /tmp/claude-*/*) exit 0 ;;                 # session scratchpad
  "$HOME"/.claude/projects/*) exit 0 ;;      # memory files
esac
# A forge agent's project directory is a worktree; its run directory sits beside it.
if [[ "$root" =~ ^(.+)/\.forge/worktrees/([0-9]+)/[^/]+$ ]]; then
  [[ "$real" == "${BASH_REMATCH[1]}/.forge/runs/${BASH_REMATCH[2]}/"* ]] && exit 0
fi
echo "Blocked: $real is outside $root. Ask the user before editing another project." >&2
exit 2
