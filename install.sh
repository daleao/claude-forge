#!/usr/bin/env bash
# Install Forge's project files into a repo, and its entries into your own
# Claude Code settings. Safe to re-run: existing files are left alone, and
# settings are only added to, never changed or removed.
#
#   bash install.sh [target repo, default: current directory]
#
# FORGE_SKIP_SETTINGS=1 leaves ~/.claude alone.
# This does not install the Claude Code plugin itself; see the README.

set -euo pipefail

here="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
target="$(cd "${1:-.}" && pwd)"

git -C "$target" rev-parse --git-dir >/dev/null 2>&1 || { echo "install: $target is not a git repository" >&2; exit 1; }

put() { # <source> <destination>
  if [[ -e "$2" ]]; then echo "  kept     ${2#"$target"/}"
  else mkdir -p "$(dirname "$2")"; cp "$1" "$2"; echo "  created  ${2#"$target"/}"; fi
}

echo "Forge project files in $target:"
put "$here/templates/config.sh" "$target/.forge/config.sh"
put "$here/templates/constitution.md" "$target/.forge/constitution.md"
# What Forge writes under .forge/ and nobody commits. An existing file gains
# the lines it lacks and keeps everything else.
ignore="$target/.forge/.gitignore"; had=0; added=""
[[ -e "$ignore" ]] && had=1
for d in runs worktrees qa handoffs reports; do
  grep -qxF "$d/" "$ignore" 2>/dev/null || { printf '%s/\n' "$d" >> "$ignore"; added+=" $d/"; }
done
if (( ! had )); then echo "  created  .forge/.gitignore"
elif [[ -n "$added" ]]; then echo "  updated  .forge/.gitignore (added$added)"
else echo "  kept     .forge/.gitignore"; fi

bin="${FORGE_BIN_DIR:-$HOME/.local/bin}"
mkdir -p "$bin"
ln -sfn "$here/scripts/forge" "$bin/forge"
ln -sfn "$here/scripts/usage-statusline.sh" "$bin/forge-usage-statusline"
echo "Linked $bin/forge -> $here/scripts/forge"
echo "Linked $bin/forge-usage-statusline -> $here/scripts/usage-statusline.sh"
case ":$PATH:" in *":$bin:"*) ;; *) echo "  note: $bin is not on your PATH" ;; esac

# Your own Claude Code settings: the hook that keeps edits inside the project
# (and, for a forge agent, its run directory), and the entries in
# templates/sandbox-settings.json. Lists gain the entries they lack; a value
# you already set is kept. A sandboxed session cannot write here, so this part
# then has to be run from your own terminal.
settings() {
  local dir="$HOME/.claude" file="$HOME/.claude/settings.json" hook="$HOME/.claude/hooks/workspace-only.sh"
  local read_rule current merged tmp
  echo "Claude Code settings in $dir:"
  command -v jq >/dev/null 2>&1 || { echo "  skipped  jq is not installed"; return 0; }
  if [[ -e "$hook" ]]; then echo "  kept     hooks/workspace-only.sh"
  elif mkdir -p "$dir/hooks" 2>/dev/null && cp "$here/templates/workspace-only.sh" "$hook" 2>/dev/null; then
    chmod +x "$hook"; echo "  created  hooks/workspace-only.sh"
  else echo "  FAILED   hooks/workspace-only.sh: cannot write here (a sandboxed session cannot). Run this script from your own terminal."; return 0; fi

  case "$here" in "$HOME"/*) read_rule="Read(~/${here#"$HOME"/}/**)" ;; *) read_rule="Read(/$here/**)" ;; esac
  current='{}'; [[ ! -s "$file" ]] || current="$(cat "$file")"
  merged="$(jq --slurpfile t "$here/templates/sandbox-settings.json" --arg read "$read_rule" '
    def add($t):
      if type == "object" and ($t | type) == "object" then
        reduce ($t | keys_unsorted[]) as $k (.; if has($k) then .[$k] |= add($t[$k]) else .[$k] = $t[$k] end)
      elif type == "array" and ($t | type) == "array" then . + ($t - .)
      else . end;
    $t[0] as $t
    | add($t | del(.hooks))
    | if any(.hooks.PreToolUse[]?.hooks[]?.command // ""; test("workspace-only\\.sh")) then .
      else .hooks.PreToolUse += $t.hooks.PreToolUse end
    | .permissions.allow |= (. + ([$read] - .))
    | if has("statusLine") then . else .statusLine = {type: "command", command: "forge-usage-statusline"} end
  ' <<<"$current" 2>/dev/null)" || { echo "  FAILED   settings.json is not valid JSON; nothing was changed"; return 0; }
  if [[ "$(jq -S . <<<"$current")" == "$(jq -S . <<<"$merged")" ]]; then echo "  kept     settings.json (every forge entry is already there)"; return 0; fi
  tmp="$file.forge-new"
  if { printf '%s\n' "$merged" > "$tmp"; } 2>/dev/null; then
    if [[ -e "$file" ]]; then cp "$file" "$file.forge-backup"; mv "$tmp" "$file"; echo "  updated  settings.json (the previous one is settings.json.forge-backup)"
    else mv "$tmp" "$file"; echo "  created  settings.json"; fi
    echo "           It takes effect in a new session."
  else echo "  FAILED   settings.json: cannot write here (a sandboxed session cannot). Run this script from your own terminal."; fi
}
[[ -n "${FORGE_SKIP_SETTINGS:-}" ]] || { echo; settings; }

echo
echo "Next: set FORGE_VERIFY_CMD in .forge/config.sh (or run /forge:setup to be walked through it)."
