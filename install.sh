#!/usr/bin/env bash
# Install Forge's project files into a repo. Safe to re-run: existing files
# are left alone.
#
#   bash install.sh [target repo, default: current directory]
#
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
if [[ ! -e "$target/.forge/.gitignore" ]]; then
  printf 'runs/\nworktrees/\n' > "$target/.forge/.gitignore"; echo "  created  .forge/.gitignore"
else echo "  kept     .forge/.gitignore"; fi

bin="${FORGE_BIN_DIR:-$HOME/.local/bin}"
mkdir -p "$bin"
ln -sfn "$here/scripts/forge" "$bin/forge"
ln -sfn "$here/scripts/usage-statusline.sh" "$bin/forge-usage-statusline"
echo "Linked $bin/forge -> $here/scripts/forge"
echo "Linked $bin/forge-usage-statusline -> $here/scripts/usage-statusline.sh"
case ":$PATH:" in *":$bin:"*) ;; *) echo "  note: $bin is not on your PATH" ;; esac

echo
echo "Next: set FORGE_VERIFY_CMD in .forge/config.sh (or run /forge:setup to be walked through it)."
