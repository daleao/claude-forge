# Forge

A workflow for building software with Claude Code: you and the agent sharpen an idea together, then the agent builds it unattended and brings it back for your review.

```text
 YOU + AGENT (one session)              UNATTENDED (forge script)              YOU
┌───────────────────────────┐   ┌────────────────────────────────────────┐   ┌────────┐
│ 1 grill   2 spec  3 slice │ → │ 4 run: frontier → Ralph loop → merge   │ → │5 review│
│ design    PRD/    vertical│   │        per slice    (TDD inside)       │   │ merge /│
│ tree      FDD     slices  │   │        then QA audit + fix rounds → PR │   │ revise │
└───────────────────────────┘   └────────────────────────────────────────┘   └────────┘
```

What you get:

- **Discovery that asks only what matters.** An interview in rounds, a spec sized to the work, and vertical slices published as a task graph of GitHub issues.
- **An unattended build loop.** Each slice runs in its own worktree, in fresh headless contexts, until a gate you define passes. Slices that don't block each other run in parallel.
- **Test-first increments.** Red before green, one commit per increment.
- **Coherence over a long build.** A durable state file per slice, a fresh context per iteration, and a guard that checkpoints before the context window fills.
- **Proof, not claims.** The script runs the gate itself, three independent reviewers audit the result, and fix rounds are bounded.
- **A human decision at the end.** The run produces a PR and a report that leads with what needs your judgement. Nothing merges into your base branch without you.

Forge builds on four open-source projects; see [Credits](#credits).

## Requirements

- Claude Code 2.1 or newer
- `git`, `jq`, `bash` ≥ 5.1
- The GitHub CLI `gh`, authenticated. Specs and slices are GitHub issues; the result is a PR.

## Install

**1. The plugin** (skills, QA agents, context-guard hook). Clone the repository somewhere permanent, since the `forge` command is linked from it, then install from that folder:

```bash
git clone https://github.com/daleao/claude-forge.git
claude plugin marketplace add /path/to/claude-forge
claude plugin install forge@forge-local
```

This folder is its own single-plugin marketplace (`.claude-plugin/marketplace.json`). To try it without installing, start a session with `claude --plugin-dir /path/to/claude-forge`. The `forge` script passes `--plugin-dir` to the headless contexts it starts, so the loop works either way; set `FORGE_NO_PLUGIN_DIR=1` if your Claude Code version objects to loading it from disk alongside an installed copy.

**2. Each repo**, once. In a Claude Code session inside the repo:

```
/forge:setup
```

Setup does the work itself and ends with two lists: what it **did for you**, and what **needs you**, each item with the exact file or command and an offer to do it. It:

- checks the tools;
- runs `install.sh`, which creates `.forge/config.sh`, `.forge/constitution.md`, `.forge/.gitignore` and links `forge` and `forge-usage-statusline` into `~/.local/bin`;
- finds your project's test, typecheck and lint commands, writes them into the config as the gate, and runs it to prove it passes;
- checks GitHub access with `forge doctor`, offers the [sandbox settings](#sandboxed-sessions) if the session is sandboxed, and adds two pointer lines to `CLAUDE.md`;
- offers to add the usage status line to your `~/.claude/settings.json`.

To do the file part by hand: `bash /path/to/claude-forge/install.sh /path/to/repo`.

**What depends on your project** is two settings in `.forge/config.sh`; everything else has a working default.

| Setting | Existing project | New project |
| --- | --- | --- |
| `FORGE_VERIFY_CMD`, the gate: one command that exits 0 only when tests, typecheck and lint all pass | found and filled in by `/forge:setup` | left empty; written by the foundation slice during `forge run`, from the spec |
| `FORGE_SETUP_CMD`: what a fresh checkout runs first (install dependencies) | same | same |

The gate is what the whole unattended phase steers by. The script refuses to run without one, unless the spec has a foundation slice that will create it.

Defaults you get without doing anything: the base branch is detected; agents may use file tools, basic git, and whatever commands your gate and setup commands start with; three slices in parallel; a run pauses at 90% subscription usage once the status line is recording it.

## Uninstall

**From the machine:**

```bash
claude plugin uninstall forge@forge-local
claude plugin marketplace remove forge-local
rm ~/.local/bin/forge ~/.local/bin/forge-usage-statusline   # the links install.sh created
rm -rf ~/.cache/forge          # the recorded usage reading, if you used the threshold
```

If you set the `statusLine` entry in `~/.claude/settings.json` to `forge-usage-statusline`, remove that entry too.

**From a repo.** Merge or abandon any run in progress first; this deletes its state.

```bash
rm -rf .forge                                    # config, constitution, run state, worktrees
git worktree prune                               # forget the worktrees just deleted
git branch --list 'forge/*' | xargs -r git branch -D          # local branches the loop created
gh label delete "forge:spec" --yes; gh label delete "forge:slice" --yes
```

Then remove the two pointer lines `/forge:setup` added to `CLAUDE.md`, and commit. Integration branches pushed to GitHub (`forge/<spec>/integration`) are deleted there, or by the PR's "delete branch" button on merge.

Not removed: `GLOSSARY.md` and `docs/adr/` (your project's documentation), and the issues and PRs on GitHub (your project's history).

## The workflow, step by step

### Starting from an empty folder

You don't set anything up first, and nothing is scaffolded before the design is agreed. The same five steps apply, with these differences:

1. **Grill** works in an empty folder. The interview also settles the project foundation: stack, test runner, layout.
2. **Spec** records those choices in a "Project foundation" section, including what the gate command will be. When it is ready to publish and finds no repository, it runs `git init`, installs the Forge files, allows the tools the scaffold will need, and creates the GitHub repository after confirming its name and visibility with you. No application code, and no gate yet.
3. **Slice** makes the first slice a **foundation slice** (marked `## Foundation`): the scaffold, the checks, the gate command written into `.forge/config.sh`, and one tracer test through the real entry point.
4. **Run** normally refuses to start without a passing gate. With a foundation slice present it starts anyway, runs that slice alone, and holds every other slice until it has merged. That slice cannot finish until the gate it wrote passes; the audit later checks that gate against the one the spec named.

### Step 1: Grill (you + agent)

```
/forge:grill I want users to be able to import contacts from a CSV
```

The agent maps your idea as a design tree and interviews you in rounds: the questions it can ask now, numbered, each with its recommended answer. You answer in bulk; the next round covers what your answers unlocked.

It asks only what earns a question: a decision that changes what gets built and that it can't settle itself. Facts it looks up. Everything else it decides, and lists at the end of each round as "Defaults I chose", so you can overturn one by its number without being asked about all of them. You can end the interview whenever you like; whatever is still open is then shown as *assumed*. Along the way it writes domain terms to `GLOSSARY.md` and hard-to-reverse decisions to `docs/adr/`.

Two detours are available mid-interview: **research** (a background agent reads primary sources and leaves cited notes) and **prototype** (throwaway code to answer a question you can't settle on paper).

It ends with a written-back understanding (problem, goals, non-goals, constraints, decisions, unknowns), each line marked *said* or *assumed*. Confirm it.

**Stay in the same session for steps 2 and 3.** The spec is written from this conversation.

### Step 2: Spec (you + agent)

```
/forge:spec
```

The agent announces a tier, which you can override:

| Tier | You get |
| --- | --- |
| Small | acceptance criteria only, as one slice issue (skip step 3) |
| Medium | FDD |
| Large | PRD + FDD |
| Architectural | PRD + FDD + ADRs |

It agrees the test **seams** with you (the unattended build tests only at seams the spec names), writes the document with numbered, observable acceptance criteria (`AC-1`, `AC-2`, …), reviews its own draft, and waits for your explicit approval before publishing it as a GitHub issue labelled `forge:spec`.

### Step 3: Slice (you + agent)

```
/forge:slice 42
```

The spec becomes vertical slices: each a thin, complete, demoable path through every layer. Each slice declares what it is **blocked by**, which acceptance criteria it **covers**, and which modules it **touches**. The agent checks that every criterion is covered, shows you the waves the dependencies allow, and after your approval publishes one issue per slice and appends a `## Slices` list to the spec issue.

Those three fields are what make parallel execution safe: blocking edges order the work, and two slices that touch the same module never run at the same time.

### Step 4: Run (unattended)

```bash
forge run 42                  # from a terminal, in the repo
forge run 42 --yolo           # no permission checks: containers and VMs only
forge run 42 --local          # no push, no PR; the report stays on disk
```

or `/forge:run 42` for a preflight and a background launch from inside a session.

What happens, without you:

1. **Snapshot.** The spec and slice issue bodies are copied to `.forge/runs/42/`. Agents read those files, never GitHub, and never issue comments.
2. **Integration branch.** `forge/42/integration` is cut from your base branch in its own worktree under `.forge/worktrees/`. Your checkout is not touched. The gate must pass here before anything starts.
3. **Frontier scheduling.** Every slice whose blockers have merged, and which shares no touched module with a running slice, starts in its own worktree, up to `FORGE_MAX_PARALLEL`. As slices merge, the slices they were blocking start.
4. **The Ralph loop, per slice.** A fresh headless `claude -p` context reads the constitution, the ticket, the slice's **state file** and the spec, then builds increments test-first: red, green, commit, record in the state file. When the context guard warns that the window is filling, it checkpoints and ends; a new context picks up from the state file. This repeats until the agent sets `Status: done`.
5. **The gate.** The script does not take "done" on trust: it runs `FORGE_VERIFY_CMD` itself. Red means the slice is reopened with the failing output written into its state file.
6. **Merge.** A done slice is merged into the integration branch. Conflicts go to a resolver agent; the gate runs again on the merged result, and a red gate gets one fix attempt before the merge is undone.
7. **QA.** Three reviewers run in parallel, read-only, each from the diff and the spec, none shown the implementers' notes: **spec** (is each criterion really met: exists, substantive, wired), **tests** (would the tests catch the requirements breaking), **code** (standards, design lenses, regressions, safety). Blocking findings go to one fixer, then a scoped recheck, for at most `FORGE_QA_MAX_ROUNDS` rounds.
8. **PR.** A draft PR is opened at the first merge and updated at the end with the report. It is marked ready when every slice merged.
9. **Cleanup.** The record of what a run leaves on the machine is written ahead, not recalled. Before an agent creates anything outside its worktree (a container, a volume, a running process, a temp file, a cache, a downloaded browser), it records the intent: what it is about to create, with which command, and how to remove it. The script does the same for its worktrees and setup command. Under that, a hook writes every Bash command an agent runs to a journal before the command runs, so a footprint the agent never recorded can still be found, and a command that cannot be journaled does not run. Both are on disk at once and join one registry, `.forge/runs/42/cleanup-registry.md`, however the agent call ends; a killed run's records are swept in by the next `forge run` or `forge cleanup`. When the run ends, a cleanup agent checks each record against the machine, removes what is safe, and writes its reasoning back to the registry. What it judges unsafe (anything outside `.forge/`, anything shared, data, installed packages) it leaves alone and writes to `.forge/runs/42/cleanup-manual.md`, with what it is, why it was left, and the command to remove it.

**If usage runs out mid-run**, the script pauses instead of failing. A failed agent call (usage limit, network, crash) is told apart from an agent that made no progress: nothing is parked, each running slice stops before its next iteration with its state intact, and the script exits with status 75 and a `paused:` line. An audit that could not finish is reported as **incomplete**, never as clean, and the PR is left as it was. Run `forge run 42` again after the limit resets and it continues where it stopped.

To pause *before* the limit, use `forge-usage-statusline` as your status line (`/forge:setup` offers to add it); the threshold, `FORGE_USAGE_STOP_PERCENT`, defaults to 90. Claude Code reports the 5-hour and 7-day percentages only to the status line, only in interactive sessions, and only on Pro and Max plans, so the reading is as fresh as your last interactive activity; a reading older than `FORGE_USAGE_MAX_AGE` (15 minutes) is ignored and the script says so. The check runs before every slice start, every iteration, and every audit step.

Things that stop a slice instead of guessing: an architectural change the spec didn't sanction, a dependency that fails to install, a destructive operation, a contradiction between ticket and spec, three failed fixes for the same problem, a stall that survives a model escalation, or the iteration budget. A parked slice holds back only the slices behind it.

Everything else the agent decides and writes down as a **ruling**: what it decided, why, what it costs if wrong. You read every one at review.

Watching and steering:

```bash
forge status 42               # each slice: status, and what parked or blocks it
forge unblock 42 57           # after editing slice 57's state.md with your answer
forge run 42                  # resumes: merged slices are kept
forge qa 42                   # re-run the QA phase alone
forge cleanup 42              # run the cleanup pass (a paused or interrupted run has had none)
```

### Step 5: Review (you)

```
/forge:review 42
```

The agent starts with what the run left on your machine: what the cleanup pass removed, and the steps it left for you. `/forge:cleanup 42` takes you through those one at a time, checking each item, showing the command, and waiting for your answer before anything is removed.

Then it briefs you from the report, decisions first: slices that didn't merge, findings still open, findings the fixer declined (with both sides), and every ruling. Then the questions no audit answers: is this what you wanted, does it behave right when you use it, are the trade-offs acceptable, would you maintain it.

- Small corrections are made on the spot, test-first.
- Bigger rework becomes new slices appended to the spec; `forge run 42` builds only those and re-audits.
- When you're satisfied, merge the PR (its `Closes` lines resolve the issues), then `forge clean 42`.

Afterwards, `/forge:retro 42` turns the run's stalls, rulings and QA findings into improvements to the agents' environment: a new check in the gate, a constitution rule, a slicing habit.

## Where everything lives

The project memory hierarchy, and who reads what:

| Layer | Location | Read by |
| --- | --- | --- |
| Constitution: permanent engineering rules | `.forge/constitution.md` | every loop iteration; QA code reviewer |
| Domain: vocabulary | `GLOSSARY.md` | everyone |
| Decisions | `docs/adr/` | everyone; binding on implementers |
| Specs and slices | GitHub issues `forge:spec`, `forge:slice` | humans; snapshotted for agents |
| Slice state: criteria + evidence, decisions, rulings, next action | `.forge/runs/<spec>/slices/<n>/state.md` | the next iteration of that slice |
| Run state: ledger, statuses, logs, QA report | `.forge/runs/<spec>/` | the script; you; `/forge:retro` |
| Cleanup registry: what each agent and the script left on the machine, and the cleanup pass's verdicts | `.forge/runs/<spec>/cleanup-registry.md` | the cleanup pass; you |
| Manual cleanup: the steps the pass would not take, with instructions | `.forge/runs/<spec>/cleanup-manual.md` | you; `/forge:review`, `/forge:cleanup` |
| Coding standards (optional) | `CODING_STANDARDS.md` | QA code reviewer only |

`.forge/runs/` and `.forge/worktrees/` are git-ignored. Delete a run directory to forget a run.

## What's in this folder

```
.claude-plugin/plugin.json   plugin manifest
scripts/forge                scheduler + Ralph loop + QA + PR (bash)
scripts/usage-statusline.sh  status line that records subscription usage for the threshold
install.sh                   per-repo project files, links `forge` onto PATH
prompts/                     what each headless context is told
  implement.md                 one loop iteration on a slice
  merge.md                     resolve a merge conflict
  integrate-fix.md             gate red after a clean merge
  qa-fix.md                    fix a round of QA findings
  footprint.md                 added to each of the above: record the intent before creating anything on the host
  cleanup.md                   the cleanup pass at the end of a run
agents/                      the QA reviewers (by axis, not persona)
  qa-spec.md  qa-tests.md  qa-code.md  qa-recheck.md
hooks/                       context guard (PostToolUse); command journal for the cleanup registry (PreToolUse)
templates/                   config.sh, constitution.md, state.md, sandbox-settings.json
skills/
  grill  spec  slice  run  review          the five steps (user-invoked)
  grilling  domain-modeling                discovery primitives
  tdd  debugging  verification             implementation disciplines
  codebase-design                          deep-module vocabulary
  qa (+ lenses/)                           the audit by hand; book-derived review lenses
  research  prototype                      detours during discovery
  retro  cleanup  architecture-survey  handoff   around the flow
  setup (+ NEW-PROJECT.md)  help           once per repo, or from an empty folder; the map
LICENSE                      MIT, for this project
licenses/                    MIT licences of the four source projects
LINEAGE.md                   where each part came from, and why it is the way it is
```

## Configuration

`.forge/config.sh`, all optional except the first:

| Setting | Default | Meaning |
| --- | --- | --- |
| `FORGE_VERIFY_CMD` | none, required (a new project's foundation slice writes it) | the gate |
| `FORGE_SETUP_CMD` | empty | run in each fresh worktree, and on the integration worktree after each merge (install deps) |
| `FORGE_BASE_BRANCH` | the repo's default branch, detected | integration branch is cut from it; the PR targets it |
| `FORGE_MAX_PARALLEL` | 3 | slices running at once |
| `FORGE_MAX_ITERATIONS` | 10 | fresh contexts per slice before it is parked |
| `FORGE_STALL_LIMIT` | 2 | no-progress iterations before escalating the model; again before parking |
| `FORGE_QA_MAX_ROUNDS` | 2 | QA fix-and-recheck rounds |
| `FORGE_MODEL_IMPLEMENT` / `_ESCALATE` / `_QA` | `sonnet` / `opus` / `opus` | model per role |
| `FORGE_MODEL_CLEANUP` | same as `FORGE_MODEL_QA` | model for the cleanup pass |
| `FORGE_CLEANUP_TOOLS` | empty; the config template sets it to: inspect Docker and processes, stop and remove containers and networks | everything the cleanup pass may run besides reading files, `--yolo` or not; a removal outside this list becomes a manual step |
| `FORGE_USAGE_STOP_PERCENT` | 90 | pause when 5-hour or 7-day usage reaches this percentage; `""` switches it off |
| `FORGE_USAGE_MAX_AGE` | 900 | seconds before a usage reading is treated as stale and ignored |
| `FORGE_ALLOWED_TOOLS` | file tools and basic git | what agents may do without `--yolo`; the commands your gate and setup commands start with are added automatically |
| `FORGE_CTX_WARN` / `FORGE_CTX_CRITICAL` | 100000 / 140000 | context guard thresholds in tokens: finish the increment, then checkpoint now |

## Safety

- **Permissions.** By default agents run with `--permission-mode acceptEdits` plus your allowlist; anything else is denied. QA reviewers get read-only tools. `--yolo` removes all checks and is meant for a container or VM.
- **Untrusted text.** An unattended agent acts on what it reads. The script feeds agents issue *bodies* only, never comments, and snapshots them once. Run it on specs you or people you trust wrote.
- **Your checkout.** All work happens in worktrees under `.forge/`. The script only ever pushes the integration branch, and never merges into your base branch; you do that, through the PR.
- **Cleanup.** The cleanup pass removes things from your machine unattended, so its limits do not rest on its judgement alone. It runs from the run directory, cannot edit code, is never given `rm`, and may run only `FORGE_CLEANUP_TOOLS`, even under `--yolo`. Anything it may not run, and anything outside `.forge/`, shared, holding data or installed, is left for you in `cleanup-manual.md`. The registry has two layers: the agents' intents, and a command journal that does not depend on them. What neither covers is not found: what the gate and setup commands leave when the script runs them, and anything an agent runs with the plugin's hooks not loaded.
- **Dependencies.** A failed package install parks the slice instead of trying a similar name, since a name that doesn't resolve may be a hallucinated or squatted package.

## Sandboxed sessions

Forge works with Claude Code's Bash sandbox switched on, without opening the sandbox to GitHub. A session never calls `gh`. It calls a few fixed `forge` commands, and only those run outside the sandbox, so the commands a session or an agent runs (your tests, anything a package installs) still have no network and no access to your GitHub token:

| Command | What it can do |
| --- | --- |
| `forge issue view <n>` | print an issue's title, state, labels and body (never its comments) |
| `forge issue create <spec\|slice> --title … --body-file …` | open an issue with the matching `forge:` label |
| `forge issue edit <n> --body-file …` | replace the body of an issue that already carries a `forge:` label |
| `forge pr view <spec>` | show the run's PR and the files it changes |
| `forge pr push <spec>` | push `forge/<spec>/integration`, and no other branch |
| `forge doctor` | check the tools, the GitHub login and the remote |

They act on the `origin` repository only, take no other flags, and do not read `.forge/config.sh`, so a session cannot steer them with a file it wrote. Anything else on GitHub (creating a repository, merging a PR, deleting labels) you do yourself.

The settings are in [`templates/sandbox-settings.json`](templates/sandbox-settings.json); `/forge:setup` offers to merge them into your `~/.claude/settings.json`. They do three things:

- `sandbox.excludedCommands` takes those commands, plus `forge run`, `forge qa` and `forge cleanup` (which start the headless agents; the first two also push), out of the sandbox. `forge status`, `unblock` and `clean` stay inside it.
- `permissions` lets the read-only commands run without a prompt and asks before each one that writes or launches a run.
- `sandbox.filesystem.denyRead` hides `~/.config/gh` from sandboxed commands. If `gh` keeps its token in your system keyring this changes nothing; it is there for the plain-file case.

Two things to know. A `forge` command must be the whole Bash call: a pipe, a redirect, a `cd` or a second command keeps the call sandboxed, so use `forge run <spec> --log <file>` to capture a run's output. And if your organisation locks the sandbox in managed settings, `excludedCommands` in your own files may be ignored; ask your administrator to add them.

### What a run can reach

A run has two kinds of command, and the sandbox treats them differently:

- **The script's own commands run outside the sandbox**, because `forge run` does. That covers the setup command and the gate each time the loop runs them: they have your network, your Docker daemon and your full file access.
- **The agents' commands run inside it.** Each headless agent reads the same settings as your session, so an implementer running the gate itself gets no network, no Unix sockets, and write access only to its worktree and the temp directory.

A gate that needs none of those works with no further setup. A gate that does will pass when the script runs it and fail when an agent runs it, so the agent cannot check its own work and the slice spends its iterations finding out from the loop. Three things commonly need opening, in the project's committed `.claude/settings.json` (a worktree is a checkout, so it carries committed files and not `.claude/settings.local.json`):

| The agent needs | Symptom inside the sandbox | Setting |
| --- | --- | --- |
| a package registry | `CONNECT tunnel failed, response 403` | `sandbox.network.allowedDomains` |
| a tool's cache under your home directory | `Read-only file system` | `sandbox.filesystem.allowWrite` |
| the Docker daemon (`docker`, Compose, Testcontainers) | `permission denied` on the Docker socket | `sandbox.excludedCommands` |

The first two keep the command sandboxed. Docker cannot work inside the sandbox, so the commands that reach it have to leave it. Name the narrowest command that does: the test command, not the tool.

```json
{
  "sandbox": {
    "excludedCommands": ["dotnet test *", "pnpm run e2e *"],
    "network": { "allowedDomains": ["api.nuget.org", "registry.npmjs.org"] },
    "filesystem": { "allowWrite": ["~/.nuget", "~/.local/share/NuGet", "~/.local/share/pnpm"] }
  }
}
```

An excluded command runs with your full access, and a test command runs code the agent wrote. Once one is excluded, the sandbox no longer keeps an agent away from your network or your GitHub token; it still stops everything the agent runs by other means. If you need that boundary to hold, run Forge inside a virtual machine or a dev container, or give `gh` a token scoped to the one repository.

An excluded command must also be the whole Bash call. `dotnet test apps/api` leaves the sandbox; `cd apps/api && dotnet test`, `dotnet test | tail` and a gate that chains it after a command with no entry of its own all stay inside. Say so in the project's `CLAUDE.md`, so agents run those commands bare.

## Status

Forge is new. The script has been tested end to end against stub `gh` and `claude` binaries, covering parallel slices, merge conflicts, stalls, pauses and resumes, and the QA rounds; it has had little use against real projects yet. Start with a small spec and `--max-parallel 1`, and expect to tune `FORGE_ALLOWED_TOOLS` and the prompts for your project. Issues and pull requests are welcome.

## Credits

Forge selects and adapts ideas from four MIT-licensed projects, whose licences are in [`licenses/`](licenses/):

- [Matt Pocock's skills](https://github.com/mattpocock/skills): the interview, the spec and vertical slicing, and much of the TDD discipline
- [Superpowers](https://github.com/obra/superpowers) (Jesse Vincent): TDD, verification before claims, worktree practice
- get-shit-done (Lex Christopherson; now continued as [gsd-core](https://github.com/open-gsd/gsd-core)): durable state across fresh contexts
- agent-rules-books (Maciej Ciemborowicz): the constitution and the review lenses

[LINEAGE.md](LINEAGE.md) records, file by file, what each part was based on, what was added, what was cut, and why.

## License

[MIT](LICENSE)
