#!/usr/bin/env bash
# Tests for scripts/forge against stub `gh` and `claude` binaries (tests/stubs),
# in scratch repositories under tests/.scratch. No network, no model calls.
#
#   tests/run.sh
#
# Each stub claude call leaves its arguments, its kind and its prompt in a
# directory of its own per step, and the checks read those.

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORGE="$HERE/../scripts/forge"
S="$HERE/.scratch"
rm -rf "$S"; mkdir -p "$S/home" "$S/issues"

export HOME="$S/home" XDG_CACHE_HOME="$S/home/.cache"
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.invalid GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.invalid
export FORGE_CLAUDE_BIN="$HERE/stubs/claude" FORGE_GH_BIN="$HERE/stubs/gh" FORGE_TEST_ISSUES="$S/issues"
unset FORGE_TEST_MCP_STATUS FORGE_TEST_FINDING GH_REPO

echo '{"number":1,"title":"Spec one","body":"Build the thing.","state":"OPEN"}' > "$S/issues/1.json"

pass=0; failed=0
ok() { pass=$((pass + 1)); printf 'ok    %s\n' "$1"; }
no() { failed=$((failed + 1)); printf 'FAIL  %s\n' "$1"; [[ -z "${2:-}" ]] || printf '      %s\n' "$2"; }
check() { local what="$1"; shift; if "$@"; then ok "$what"; else no "$what"; fi; }
has() { grep -qF -- "$2" "$1" 2>/dev/null; }           # <file> <text>
lacks() { ! grep -qF -- "$2" "$1" 2>/dev/null; }
has_arg() { grep -qxF -- "$2" "$1" 2>/dev/null; }      # <args file> <one whole argument>
lacks_arg() { ! grep -qxF -- "$2" "$1" 2>/dev/null; }

# step <name>: the stub's calls from here on go to their own directory.
step() { export FORGE_TEST_CALLS="$S/calls/$1"; OUT="$S/out-$1.txt"; printf '\n# %s\n' "$1"; }
# calls <kind>: the call files (without extension) of that kind in this step.
calls() { local k; for k in "$FORGE_TEST_CALLS"/*.kind; do [[ -f "$k" && "$(cat "$k")" == "$1" ]] && echo "${k%.kind}"; done; return 0; }
first() { calls "$1" | head -n1; }
# allowed <args file>: what follows --allowedTools, one per line.
allowed() { sed -n '/^--allowedTools$/,$p' "$1" | tail -n +2; }
forge() { ( cd "$R" && "$FORGE" "$@" ) > "$OUT" 2>&1; }

# new_repo <name> [untracked]: a repo with a config, a passing gate and a
# constitution, committed on main (or left untracked).
new_repo() {
  R="$S/$1"; mkdir -p "$R/.forge"; git -C "$R" init -q -b main
  cat > "$R/.forge/config.sh" <<'EOF'
FORGE_VERIFY_CMD="true"
FORGE_NOTIFY_CMD=":"
FORGE_USAGE_STOP_PERCENT=""
EOF
  printf 'runs/\nworktrees/\n' > "$R/.forge/.gitignore"
  printf '# Constitution\n\n- Rule one.\n\n## Middle\n\n- Rule two.\n\n## Project-specific rules\n\n- Rule three.\n' > "$R/.forge/constitution.md"
  echo readme > "$R/README.md"
  git -C "$R" add -A
  [[ "${2:-}" != untracked ]] || git -C "$R" rm -q --cached .forge/constitution.md
  git -C "$R" commit -qm "initial"
}

READ_ONLY=$'Read\nGrep\nGlob\nBash(git diff:*)\nBash(git log:*)\nBash(git show:*)'

# ------------------------------------------------- a run, no reviewer tools --
new_repo a; INT="$R/.forge/worktrees/1/integration"; REPORT="$R/.forge/runs/1/qa/report.md"
step run
forge run 1 --local; check "forge run finishes" test $? -eq 0
i="$(first implement)"; c="$(first code)"
check "the implementer is given its own worktree's constitution" has "$i.prompt" "\`$R/.forge/worktrees/1/slice-1/.forge/constitution.md\`"
check "with no rulings file, the implementer is told there are none" has "$i.prompt" "the human has made no rulings"
check "a slice with no choices has no check made" test -z "$(calls choices)"
for k in spec tests code; do
  check "the $k reviewer is given the integration worktree's constitution" has "$(first $k).prompt" "Constitution: $INT/.forge/constitution.md"
done
check "with FORGE_QA_TOOLS empty, a reviewer is allowed the read-only tools and nothing else" test "$(allowed "$c.args")" == "$READ_ONLY"
check "FORGE_QA_TOOLS set in a slice's checkout does not reach the reviewers" lacks_arg "$c.args" Edit
check "the report shows the constitution rule the branch added" has "$REPORT" "+- Rule added by the slice."
check "the report has no such section's worth of unchanged rules" lacks "$REPORT" "+- Rule one."
check "with FORGE_LIVE_CMD empty, the report says the live tests are not configured" has "$REPORT" "- not configured (FORGE_LIVE_CMD)"

step unchanged
forge qa 1 --local
check "an audit with nothing changed stands" has "$OUT" "nothing new since the last audit"
check "and calls no reviewer" test -z "$(calls code)"

# ------------------------------------------------------- reviewer tools set --
echo 'FORGE_QA_TOOLS=("mcp__pluggy__get_spec" "Bash(printenv PLUGGY_URL)")' >> "$R/.forge/config.sh"
step tools
FORGE_TEST_FINDING=1 forge qa 1 --local; check "forge qa finishes" test $? -eq 0
check "changing FORGE_QA_TOOLS makes the audit cover the whole branch" has "$OUT" "auditing the whole branch"
for k in spec tests code recheck; do
  a="$(first $k).args"
  check "the $k reviewer is allowed the MCP tool" has_arg "$a" "mcp__pluggy__get_spec"
  check "the $k reviewer is allowed the exact Bash entry, as one argument" has_arg "$a" "Bash(printenv PLUGGY_URL)"
  check "the $k reviewer keeps its read-only tools" test "$(allowed "$a" | head -n 6)" == "$READ_ONLY"
  check "the $k reviewer is allowed no file-writing tool" bash -c '! grep -qxE "Edit|Write|NotebookEdit" "$1"' _ "$a"
done
f="$(first other)"
check "the QA fixer is not given the reviewers' tools" lacks_arg "$f.args" "mcp__pluggy__get_spec"
check "the QA fixer is given the integration worktree's constitution" has "$f.prompt" "\`$INT/.forge/constitution.md\`"
check "the recheck is given the integration worktree's constitution" has "$(first recheck).prompt" "Constitution: $INT/.forge/constitution.md"

step yolo
forge qa 1 --local --full --yolo
a="$(first code).args"
check "--yolo: a reviewer skips permissions" has_arg "$a" "--dangerously-skip-permissions"
check "--yolo: and is passed no allowlist" lacks_arg "$a" "--allowedTools"
for f in "$HERE"/../agents/qa-*.md; do
  check "$(basename "$f") removes the file-writing tools and keeps no allowlist that would hide MCP tools" \
    bash -c 'sed -n "2,/^---$/p" "$1" | grep -qx "disallowedTools: Edit, Write, NotebookEdit, Agent" && ! sed -n "2,/^---$/p" "$1" | grep -q "^tools:"' _ "$f"
done

# --------------------------------------------------- the base branch moves --
sed -i 's/^- Rule one\.$/- Rule one.\n- Rule from the base, added mid-run./' "$R/.forge/constitution.md"
git -C "$R" commit -qm "a new rule" .forge/constitution.md
step base-merge
forge qa 1 --local; check "forge qa finishes after the base moved" test $? -eq 0
check "the base branch's new commits are merged first" has "$OUT" "merged the new commits on main"
check "the integration worktree's constitution has the base's new rule" has "$INT/.forge/constitution.md" "Rule from the base, added mid-run."
check "and keeps the slice's" has "$INT/.forge/constitution.md" "Rule added by the slice."
check "the reviewers ran on the merged branch" test -n "$(calls code)"
check "the report lists only what the branch changed" bash -c 'grep -qF -- "+- Rule added by the slice." "$1" && ! grep -qF -- "Rule from the base" "$1"' _ "$REPORT"

echo "- Rule from the base that conflicts." >> "$R/.forge/constitution.md"
git -C "$R" commit -qm "a conflicting rule" .forge/constitution.md
before="$(git -C "$INT" rev-parse HEAD)"
for cmd in qa run; do
  step "conflict-$cmd"
  forge "$cmd" 1 --local; rc=$?
  check "forge $cmd stops on a base conflict" test "$rc" -ne 0 -a "$rc" -ne 75
  check "forge $cmd names the conflicted file" bash -c 'grep -F "conflict" "$1" | grep -qF ".forge/constitution.md"' _ "$OUT"
  check "forge $cmd started no agent" test ! -d "$FORGE_TEST_CALLS"
  check "forge $cmd left the integration worktree as it was" test "$(git -C "$INT" rev-parse HEAD)$(git -C "$INT" status --porcelain)" == "$before"
  check "forge $cmd left no lock behind" test ! -d "$R/.forge/runs/1/.lock"
done

# --------------------------------------- no constitution on the branch yet --
new_repo b untracked
step fallback
forge run 1 --local; check "forge run finishes with an uncommitted constitution" test $? -eq 0
check "the run says the constitution is not committed" has "$OUT" ".forge/constitution.md is not committed"
check "the implementer falls back to the main checkout's copy" has "$(first implement).prompt" "\`$R/.forge/constitution.md\`"
check "the reviewers fall back to it too" has "$(first code).prompt" "Constitution: $R/.forge/constitution.md"

new_repo c; rm "$R/.forge/constitution.md"
step preflight
forge run 1 --local
check "preflight asks for the main checkout's copy when there is none" has "$OUT" "no .forge/constitution.md"
check "and starts no agent" test ! -d "$FORGE_TEST_CALLS"

# ------------------------------------------------------ doctor: MCP servers --
new_repo d
cat >> "$R/.forge/config.sh" <<'EOF'
FORGE_QA_TOOLS=("mcp__pluggy__get_spec" "mcp__pluggy__list_endpoints" "Bash(printenv PLUGGY_URL)")
#FORGE_ALLOWED_TOOLS=("mcp__ghost__anything")
EOF
step doctor-undeclared
echo '{"mcpServers":{"pluggy":{"type":"http","url":"https://example.invalid/mcp"}}}' > "$R/.mcp.json"   # present, not committed
forge doctor; check "doctor fails for a server that is not committed" test $? -ne 0
check "doctor names the server once" test "$(grep -c "MCP server 'pluggy'" "$OUT")" -eq 1
check "doctor reports the missing declaration" has "$OUT" "the committed .mcp.json does not declare it"
check "doctor reports the missing enablement" has "$OUT" "the committed .claude/settings.json does not enable it"
check "doctor ignores a server named only in a comment" lacks "$OUT" "ghost"

mkdir -p "$R/.claude"; echo '{"enabledMcpjsonServers":["pluggy"]}' > "$R/.claude/settings.json"
git -C "$R" add .mcp.json .claude/settings.json; git -C "$R" commit -qm "mcp"
step doctor-ok
forge doctor; check "doctor passes for a committed, enabled, connected server" test $? -eq 0
check "doctor says so" has "$OUT" "ok       MCP server 'pluggy'"
check "doctor asked a headless claude for the server" has_arg "$(first mcp).args" pluggy

step doctor-auth
FORGE_TEST_MCP_STATUS="! Needs authentication" forge doctor; check "doctor fails when the sign-in does not work headless" test $? -ne 0
check "doctor reports what claude said" has "$OUT" "a headless claude does not reach it: ! Needs authentication"

step doctor-disabled
echo '{"enabledMcpjsonServers":["pluggy"],"disabledMcpjsonServers":["pluggy"]}' > "$R/.claude/settings.json"
forge doctor; check "doctor fails for a server the settings disable" test $? -ne 0
check "doctor reports the disabling file" has "$OUT" "disabledMcpjsonServers in $R/.claude/settings.json rejects it"

R="$S/b"; step doctor-none
forge doctor
check "doctor has nothing to say about MCP when the config names no server" lacks "$OUT" "MCP server"

# ------------------------------------------------- rulings and choices ------
new_repo e; RUN_E="$R/.forge/runs/1"; mkdir -p "$RUN_E"
echo "- A transaction takes the currency of its Transfer, never its Account's." > "$RUN_E/rulings.md"
step contradicts
FORGE_TEST_CHOICE=1 FORGE_TEST_CONTRADICT=1 forge run 1 --local
i="$(first implement)"; k="$(first choices)"
check "the implementer is given the rulings file" has "$i.prompt" "\`$RUN_E/rulings.md\`"
check "a slice with a choice and a rulings file has its choices checked" test -n "$k"
check "the check is given the choice and the ruling" bash -c 'grep -qF "its Account'"'"'s currency" "$1" && grep -qF "never its Account" "$1"' _ "$k.prompt"
check "the check is not given the diff" lacks "$k.prompt" "diff --git"
check "the check may not write" bash -c 'sed -n "/^--disallowedTools$/,\$p" "$1" | grep -qx Write' _ "$k.args"
check "a contradiction blocks the slice" test "$(cat "$RUN_E/slices/1/status")" == blocked
check "and the slice is not merged" test ! -f "$R/.forge/worktrees/1/integration/work-slice-1.txt"
check "the contradiction is in the ledger" has "$RUN_E/ledger.md" "CONTRADICTS a transaction"
check "and in the state file" has "$RUN_E/slices/1/state.md" "  - CONTRADICTS a transaction"

( cd "$R" && "$FORGE" unblock 1 1 ) >/dev/null 2>&1
step choices-skip-qa
FORGE_TEST_CHOICE=1 forge run 1 --local --skip-qa
check "the check runs with --skip-qa" test -n "$(first choices)"
check "no contradiction: the slice merges" test "$(cat "$RUN_E/slices/1/status")" == merged

step rulings-qa
FORGE_TEST_FINDING=1 FORGE_TEST_PARK=1 forge qa 1 --local
for k in spec tests code recheck; do
  check "the $k reviewer is given the rulings file" has "$(first $k).prompt" "The human's rulings (binding): \`$RUN_E/rulings.md\`"
done
check "the QA fixer is given the rulings file" has "$(first other).prompt" "\`$RUN_E/rulings.md\`"
check "the fixer's parked finding reaches the report" has "$RUN_E/qa/report.md" "- PARKED f:1 — needs the human: which currency"
check "the report lists the agents' choices" bash -c 'grep -qF "### Choices: decisions the agents made" "$1" && grep -qF -- "- Choice: a transaction takes" "$1"' _ "$RUN_E/qa/report.md"

# ----------------------------------------------- QA context thresholds ------
printf 'export FORGE_CTX_WARN=100000 FORGE_CTX_CRITICAL=140000\nFORGE_CTX_WARN_QA=200000\nFORGE_CTX_CRITICAL_QA=280000\n' >> "$R/.forge/config.sh"
step ctx-qa
FORGE_TEST_FINDING=1 forge qa 1 --local --full
for k in spec tests code recheck; do
  check "the $k reviewer gets the QA context thresholds" test "$(cat "$(first $k).ctx")" == "200000 280000"
done
f="$(grep -l "fix round" "$FORGE_TEST_CALLS"/*.prompt | head -n1)"; c="$(grep -l "You are its cleanup pass" "$FORGE_TEST_CALLS"/*.prompt | head -n1)"
check "the QA fixer gets the QA context thresholds" test "$(cat "${f%.prompt}.ctx")" == "200000 280000"
check "the cleanup pass keeps the plain pair" test "$(cat "${c%.prompt}.ctx")" == "100000 140000"

# ------------------------------------------------------------ live tests ----
echo "FORGE_LIVE_CMD='echo ran >> live-runs.txt; exit 1'" >> "$R/.forge/config.sh"
step live
forge qa 1 --local --full; check "forge qa finishes when the live tests fail" test $? -eq 0
INT="$R/.forge/worktrees/1/integration"
check "the live tests ran once, in the integration worktree" test "$(cat "$INT/live-runs.txt")" == ran
check "their output is logged" test -f "$RUN_E/qa/live.log"
check "the report lists the failure as blocking" has "$RUN_E/qa/report.md" "- [BLOCKER] the live tests FAIL"
check "a failure starts no fix round" test -z "$(grep -l "fix round" "$FORGE_TEST_CALLS"/*.prompt 2>/dev/null)"
check "and does not fail the gate" has "$RUN_E/qa/report.md" "gate **PASS**"

printf '\n%d passed, %d failed\n' "$pass" "$failed"
(( failed == 0 ))
