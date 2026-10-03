# Forge project config. Sourced by the `forge` script (bash). Commit this file.
#
# Only the first two settings depend on your project. Everything below them
# has a working default; change a value only if you want different behaviour.

# ── Project-specific ─────────────────────────────────────────────────────────

# The gate: one command line that exits 0 only when the project is healthy
# (tests, typecheck, lint). The loop runs it before accepting a slice as done,
# after every merge, and before the audit.
#   Existing project: /forge:setup finds and fills this in.
#   New project: leave it empty. The foundation slice writes it, from the
#   spec's "Project foundation" section, as part of building the scaffold.
FORGE_VERIFY_CMD=""

# Run in every fresh worktree before work starts, and on the integration
# worktree after each merge (install deps, codegen). Keep it fast and
# repeatable, e.g. "npm ci". Filled in the same way as the gate.
FORGE_SETUP_CMD=""

# ── Defaults (optional) ──────────────────────────────────────────────────────

# Branch the integration branch is cut from, and the PR targets.
# Unset = the repository's default branch, detected automatically.
#FORGE_BASE_BRANCH="main"

# How many slices run at once.
FORGE_MAX_PARALLEL=3

# Per slice: fresh-context iterations before it is parked as blocked.
FORGE_MAX_ITERATIONS=10

# Per slice: consecutive iterations with no new commit and no state change
# before the model is escalated; the same count again parks the slice.
FORGE_STALL_LIMIT=2

# Audit: fix-and-recheck rounds before residual findings go to the human.
FORGE_QA_MAX_ROUNDS=2

# Pause the run when subscription usage (5-hour or 7-day window) reaches this
# percentage. "" = off. It takes effect once `forge-usage-statusline` is your
# Claude Code status line, and only while its readings are fresh (see
# FORGE_USAGE_MAX_AGE). A run that hits the limit itself pauses cleanly anyway.
FORGE_USAGE_STOP_PERCENT=90
FORGE_USAGE_MAX_AGE=900          # seconds before a usage reading is ignored

# Models per role (any value `claude --model` accepts).
FORGE_MODEL_IMPLEMENT="sonnet"   # slice iterations, merge resolution
FORGE_MODEL_ESCALATE="opus"      # a stalled slice, audit fixes
FORGE_MODEL_QA="opus"            # the three reviewers and the recheck

# Context guard thresholds, in tokens: when an iteration is told to finish its
# increment, and when it is told to checkpoint immediately.
export FORGE_CTX_WARN=100000
export FORGE_CTX_CRITICAL=140000

# Tools unattended agents may use without `--yolo`. On top of this list, the
# script automatically allows the commands your gate and setup commands start
# with (for "npm test && npx tsc", that is npm and npx), so most projects need
# no changes here. Add an entry for anything else an implementer needs, for
# example a scaffolding command in a new project. Anything not allowed is
# denied, and the iteration records the denial instead of stalling.
FORGE_ALLOWED_TOOLS=(
  "Read" "Edit" "Write" "Glob" "Grep" "Skill"
  "Bash(git status:*)" "Bash(git diff:*)" "Bash(git log:*)" "Bash(git show:*)"
  "Bash(git add:*)" "Bash(git commit:*)" "Bash(git merge:*)" "Bash(git checkout:*)"
  "Bash(git rm:*)" "Bash(git mv:*)" "Bash(git restore:*)" "Bash(mkdir:*)" "Bash(ls:*)"
)
