# Lineage

For every asset: what it was based on, what was added and from where, what was cut, and why.

Sources. All four were local clones beside this folder while it was built, and were removed afterwards; file paths below refer to those upstream repositories.

- **MP**: Matt Pocock's skills, github.com/mattpocock/skills (MIT)
- **SP**: Superpowers, Jesse Vincent / Prime Radiant, github.com/obra/superpowers (MIT)
- **GSD**: get-shit-done (MIT; archived, development moved to github.com/open-gsd/gsd-core)
- **ARB**: agent-rules-books, Maciej Ciemborowicz (MIT). The request described this repo as Matt Pocock's; its README and licence name Maciej Ciemborowicz as the author.
- **Brief**: the request and the recommendations pasted with it
- **New**: written for this harness

Licences are in `licenses/`.

## How the choices were made

Three observations from reading the sources shaped everything below.

**1. The three frameworks do share one skeleton, and differ in where they put control.** MP puts control in the human (small skills you invoke). SP puts it in an always-on bootstrap that makes the agent invoke skills itself, and in a controller session that runs for hours. GSD puts it in a large workflow engine (67 commands, 33 role agents, an SDK) around a `.planning/` state tree. The request ruled out always-on methodology and role agents, so MP is the base and the other two are mined for ideas, not structure.

**2. Each has one thing the others lack.**
- MP: the best discovery primitives (grilling in rounds over a design tree; a glossary as a compression device; seams agreed before testing; slices as a task graph with a frontier), and the tersest writing.
- SP: the best *distrust*. Verification before completion, "do not trust the report", scoped re-reviews, capped fix loops, and "rulings, not stalls" for unattended work. SP's skills are long because they are tuned against agents rationalising their way out of rules.
- GSD: the best *state*. A small file that is read first and updated after every action, so any agent can die and another continue; a monitor that tells the agent how full its context is; deviation rules for what an unattended executor may fix without asking; goal-backward verification (exists → substantive → wired).

**3. None of them is a Ralph loop.** MP's `implement-spec` and SP's `subagent-driven-development` both run inside one long-lived controller session that dispatches subagents; the controller's context is the single point of failure (SP's own text reports controllers that "re-dispatched entire completed task sequences" after compaction). GSD mitigates the same problem with state files. A Ralph loop removes the controller: a shell script holds the control flow, and every unit of model work is a fresh process that reads its state from disk. So the script is new, and it is where the ideas from all three meet.

The design rule throughout, from the Brief: one mechanism per job, and the jobs kept orthogonal. Decomposition decides *what*; the Ralph loop decides *how long*; TDD decides *whether an increment is right*; the state file and context guard keep the agent *coherent*; the gate and QA decide *whether it is done*.

Writing style follows MP's `writing-for-agents`: say what to do rather than what to avoid, give every step a checkable completion criterion, keep reference behind pointers, and delete instructions the model follows anyway. That is the main reason the SP-derived material here is a fraction of its original length.

## Decisions you made

| Question | Your answer | Consequence |
| --- | --- | --- |
| Ralph driver | external script | `scripts/forge`; no in-session orchestrator skill |
| Tracker | GitHub Issues | specs and slices are issues; the script snapshots bodies locally |
| Spec location | issue bodies only | PRD and FDD share one issue body; nothing under `docs/specs/` |
| Isolation | worktree per slice | plus an integration worktree, so your checkout is never touched |
| Permissions | allowlist by default, `--yolo` opt-in | `FORGE_ALLOWED_TOOLS`; reviewers read-only |
| Grilling pace | rounds of the frontier | MP's primitive kept as is |
| Spec ceremony | scaled to size | four tiers in `/forge:spec` |
| QA failures | bounded auto-fix | `FORGE_QA_MAX_ROUNDS`, then residuals to you |
| Book rules | review lens + small constitution | `templates/constitution.md`, `skills/qa/lenses/` |
| Harness / packaging | Claude Code only; plugin + install script | hooks, agents, `--agent`, `--plugin-dir` used directly |
| Stack | language-agnostic | everything hangs off `FORGE_VERIFY_CMD` |
| Models | tiered, configurable | implement / escalate / QA |
| Delivery | draft PR + QA report | PR body is the report |
| Extras | research, prototype, retro, architecture survey | all four included |
| Name | forge | `/forge:*`, `forge run` |

---

## Step 1: Discovery

### `skills/grilling/SKILL.md`

- **Base**: MP `productivity/grilling`. The round format, the frontier, "facts are your job, decisions are the user's" are verbatim.
- **Added from SP `brainstorming`**:
  - *Scope first*: split multi-subsystem ideas before asking detail questions. SP is right that grilling the details of something that needs decomposing wastes the whole interview; MP has no equivalent (it sends you to `wayfinder`, not included here).
  - *Real alternatives*: two or three approaches with trade-offs where a decision has them. MP's "recommended answer" covers the simple case; this covers architecture-shaped questions. SP's YAGNI clause is kept as a positive rule (options are cut down to what the goal needs).
  - *Write back, said vs assumed*: SP's "write back your understanding, separate what they said from assumptions".
- **Added from the Brief**: the six-list output shape (problem, goals, non-goals, constraints, decisions, unknowns). It gives `/forge:spec` a fixed thing to synthesise from, and turns MP's fuzzy "shared understanding" into a checkable completion criterion: no line left marked *assumed*.
- **Added (New, with one idea from GSD)**: "What earns a question". MP's primitive says to resolve *every* branch by asking, which is the source of the commonly reported complaint that it asks obvious questions. The filter: a decision is asked only when it changes what gets built *and* the agent can't settle it; everything else becomes a listed **default** the user can overturn by number. The defaults block is GSD's "assumptions mode" (`workflows/discuss-phase-assumptions.md`: "surface what you believe… ask the user only to correct what's wrong"), applied per round inside MP's interview instead of replacing it. The self-test ("if any answer but your recommendation would surprise you, it is a default") is new. The completion criterion changed with it: a branch is resolved by an answer *or* a listed default, and the user may end the session early, with the remainder shown as *assumed*.
- **Rejected**: SP's one-question-per-message pacing (you chose rounds); SP's visual companion (a browser server with telemetry, far outside this workflow's needs); SP's HARD-GATE block (the gate here is structural: nothing is built until a spec issue exists and you run the script).

### `skills/grill/SKILL.md`

- **Base**: MP `engineering/grill-with-docs`, a two-line wrapper that invokes `grilling` and `domain-modeling` together.
- **Added (New)**: the two detours (research, prototype), taken from the flow MP describes in `ask-matt`, and the instruction to stay in the session for `/forge:spec`, from `ask-matt`'s context-hygiene section.
- **Added (New)**: the new-project paragraph. In an empty folder the design tree gains a "project foundation" branch (stack, checks, layout), and nothing is scaffolded during the interview. This is your requirement that the scaffold follow the agreed spec, never precede it.
- **Why not MP's `grill-me`**: it is the same interview without the glossary. This workflow always has a repo, so the stateful variant is the only one needed.

### `skills/domain-modeling/` (3 files)

- **Verbatim** from MP `engineering/domain-modeling`. Nothing in SP or GSD does this job; GSD's `CONTEXT.md` is a per-phase decisions dump, not a ubiquitous language. The three-condition ADR test (hard to reverse, surprising, a real trade-off) is the best guard against ADR ceremony in any of the sources.
- This skill owns two layers of the Brief's memory hierarchy (domain, decisions) in MP's own layout: `GLOSSARY.md` and `docs/adr/`.

### `skills/research/SKILL.md`, `skills/prototype/` (3 files)

- **Verbatim** from MP. Requested extras. GSD has heavier equivalents (five researcher agents, `spike`, `sketch`); MP's are one page each and do the same job.

## Step 2: Specification

### `skills/spec/SKILL.md`, `skills/spec/TEMPLATES.md`

- **Base**: MP `engineering/to-spec`: no second interview, seams agreed with the user, decisions without file paths, the prototype-snippet exception. Its template sections (problem, solution, user stories, implementation decisions, testing decisions, out of scope) are all still present.
- **Added from the Brief**: the size tiers (small → criteria, medium → FDD, large → PRD + FDD, architectural → + ADR) and the PRD/FDD split. MP's single template is divided along that line: user-facing sections form the PRD part, technical sections the FDD part.
- **Added from SP `brainstorming`**: classify *out loud* so the human can override, and the one-way ratchet (take the heavier tier when unsure; complexity found later upgrades, nothing downgrades). SP's three paths (spike / bounded / architectural) map onto the tiers: SP's "bounded" is the small tier, and its "spike" is the `prototype` detour.
- **Added from SP**: the spec self-review (placeholders, contradictions, ambiguity, scope), and the rule that approving an idea is not approving a document.
- **Added from GSD**: numbered requirement IDs. GSD traces `REQ-n` from requirements through plans to verification. Here `AC-n` plays that role: slices declare which they cover, and the QA spec reviewer verdicts each one. This is what makes "did we satisfy the spec" a table, not an impression.
- **Added (New)**: a "Failure modes" section in the FDD. The Brief's QA list asks "what edge cases are missing"; that question needs something to be measured against.
- **Added (New)**: the new-project path. A "Project foundation" section in the FDD (stack, layout, checks, gate command, setup command, named dependencies), and at publish time a pointer to `skills/setup/NEW-PROJECT.md` when the folder has no repository. The gate command is *named* in the spec because, for a project that doesn't exist yet, it is a design decision; it is *written into the config* by the foundation slice, with the scaffold it depends on, not at setup. The named-dependency list is what lets the constitution's "install only what the spec names" rule hold for a scaffold.
- **Cut**: MP's "LONG, extremely extensive" emphasis on user stories is softened to "covering every aspect", since acceptance criteria now carry the precision. MP's triage labels are replaced by one label.

## Step 3: Decomposition

### `skills/slice/SKILL.md`

- **Base**: MP `engineering/to-tickets`: tracer-bullet vertical slices, blocking edges, the frontier, the quiz, the expand–contract exception for wide refactors (kept nearly verbatim; it is a subtle, correct treatment that nobody else has).
- **Why MP over SP `writing-plans` and GSD's planner**: SP plans are sequences of 2 to 5 minute steps with complete code written in advance, which suits a controller transcribing a plan and defeats a TDD loop that is supposed to discover the code. GSD plans are horizontal by default (it has a separate "MVP mode" to get vertical slices). MP's tickets are vertical and form a graph, which is the Brief's "dependency DAG" already.
- **Added from GSD**: the write-set check. GSD's `execute-phase` compares plans' `files_modified` and refuses to run overlapping plans in parallel. MP forbids file paths in tickets (they go stale), so the same idea is expressed as a **Touches** list of modules in glossary terms. The script enforces it. This implements the Brief's invariant about concurrent write sets.
- **Added from GSD**: the coverage table (every `AC-n` has a slice; every slice covers an AC), from the requirement-coverage dimension of `gsd-plan-checker`.
- **Added (New)**: a `## Verify` section per slice (how to demonstrate it once merged), reused by `/forge:review`; showing the user the waves before publishing; the `## Slices` list on the spec issue as the script's source of truth for membership (plain text, so it works without GitHub's sub-issue feature).
- **Added (New)**: the **foundation slice** for new projects: scaffold, checks, and one tracer test, marked `## Foundation`. It is MP's "prefactoring comes first" and the Pragmatic Programmer's tracer bullet applied to an empty repo. GSD and SP both scaffold as part of ordinary planned tasks; making it a marked slice is what lets the script relax its "gate must pass before work" rule for exactly one slice and no other.
- **Cut**: the local-file tracker branch, since you chose GitHub Issues.

## Step 4: Execution

### `scripts/forge`

**New.** No source has an external loop; this is the one place the harness is built, not selected. Each part has a parent:

| Part | Idea from | Notes |
| --- | --- | --- |
| Fresh `claude -p` context per iteration, loop until a condition holds | the Ralph loop (named in the Brief; no implementation in the four repos) | the Brief's refinement applied: Ralph is the primitive inside each slice, not the manager of the whole build |
| Frontier scheduling over blocking edges | MP `implement-spec` ("the tickets are a task graph… kick off more implementers when the frontier changes") | preferred over GSD's fixed waves: a slice starts the moment its blockers merge, not when the whole previous wave ends |
| No two running slices share a **Touches** entry | GSD `execute-phase` overlap check | |
| Worktree per slice, one integration branch, merge as each finishes | MP `implement-spec` | plus an integration *worktree*, so the user's checkout is untouched (New) |
| Baseline gate before any work | SP `using-git-worktrees` (verify a clean test baseline) | |
| GitHub front door (`forge issue`, `forge pr`, `forge doctor`) and `templates/sandbox-settings.json` | New | sessions never call `gh`: a few fixed verbs, pinned to `origin`, are the only commands taken out of Claude Code's Bash sandbox, so the sandbox keeps its network closed and the `gh` token out of reach |
| The script runs the gate itself after a "done" claim | SP `verification-before-completion`, moved out of the agent | SP asks the agent to verify before claiming; an unattended loop can enforce it mechanically, which is stronger than any wording |
| Durable per-slice state file, read first, updated after every increment | GSD `STATE.md` and `continue-here.md`; SP's SDD ledger | see `templates/state.md` |
| Append-only ledger, resume from disk | SP `subagent-driven-development` ("trust the ledger and git log over your own recollection") | |
| Stall detection, then model escalation, then park | SP SDD fix loop ("rounds 4-5: fresh implementer, more capable model"); GSD's fix-attempt limit | stall is measured, not self-reported: no new commit and no state-file change |
| Model per role | SP "Model Selection"; GSD model profiles | reduced to three settings |
| Diff packaged as a file for reviewers | SP `scripts/review-package` | commit list + stat + `-U10` diff |
| One fixer for all findings, scoped recheck, capped rounds | SP SDD "Final Review" | cap is configurable |
| Draft PR at first merge, ready at the end, `Closes` lines | MP `implement-spec` steps 3 and 8 | |
| Report ordered decisions-first | MP `in-progress/loop-me` ("push right"; a **brief** is decision-ready, never raw output) | |
| Issue bodies only, snapshotted once | New | an unattended agent with write access should not read text anyone can post |

Added after the first build, all **New**:

| Part | Why |
| --- | --- |
| **Pause, not park, when an agent call fails** (`halt`, exit status 75) | A call that fails (usage limit, network, crash) says nothing about the slice. The first version counted it as "no progress", so a usage limit parked every running slice as stalled within seconds. Now the exit status of each call is recorded, a failed call pauses the whole run at a safe point, and every slice stays resumable. |
| **An empty reviewer report is an incomplete audit** (`reviewer_failure`, `qa_pause`) | The first version counted findings by pattern, so a reviewer that returned nothing produced "0 blocking findings" and could mark the PR ready. A report must now contain its findings section (or, for the recheck, at least one verdict line), or the audit is reported as incomplete and the PR is left alone. This is SP's "evidence before claims" applied to the harness itself. |
| **Usage threshold** (`usage_check`, `scripts/usage-statusline.sh`) | GSD's context monitor reads a bridge file written by its status line; the same bridge is used here for a different number. Claude Code gives the 5-hour and 7-day percentages only to the status line, so a small status line script records them and the scheduler checks the file at its safe points: before starting a slice, before each iteration, before each audit step. Stale readings are ignored and the script says when it cannot enforce the threshold. |
| **Foundation slice handling** (`FOUNDATION`, `ensure_integration`) | For a new project the gate cannot pass until the scaffold exists. With a slice marked `## Foundation`, the baseline check is waived, that slice runs alone, and every other slice implicitly waits for it. Without such a slice the red-baseline refusal is unchanged. |
| **The gate is read from each checkout's own config** (`cfg`, `gate`) | Your requirement that a new project's gate be set while scaffolding, not at setup. The foundation slice writes `FORGE_VERIFY_CMD` into `.forge/config.sh` on its branch; the script reads the gate from the worktree it is judging, so the new gate applies to that slice at once and to the integration branch after the merge. A "done" claim with no gate defined is refused. Because an agent now authors the gate, the audit's spec reviewer compares it with the gate the spec named and treats a weaker one as a blocker. |
| **Permissions derived from the gate, from the human-committed config only** (`derived_tools`) | Fewer manual steps: the commands the gate and setup commands start with are allowed automatically. They are read from the config loaded at start, never from a slice's checkout, so an agent that edits the config cannot widen its own permissions. |
| **Detected base branch, built-in tool defaults, usage threshold 90 by default** | Fewer manual steps. Only the gate and setup commands depend on the project. |
| **Setup command re-run on the integration worktree after each merge** (`int_gate`) | Found while adding the foundation path: a slice that adds a dependency passes its own gate, then fails the integration gate because the integration worktree never installed it. |

**Deliberately absent**: per-slice code review. SP reviews after every task; you asked for one autonomous QA phase. Each slice gets the deterministic gate only, and the single audit sees the integrated result, which is also where cross-slice problems show.

### `prompts/implement.md`

**New**, the loop's inner prompt. Parents by section:

- *Reading order and "you start with no memory"*: the Brief's deterministic context assembly (constitution + domain + slice + state + relevant code), and GSD's "read STATE.md first".
- *Increments; record after each; end when warned*: Ralph, plus GSD's checkpoint discipline. An iteration works several increments while its context is healthy and writes state after each, so dying at any point loses at most one increment. One-increment-per-iteration (classic Ralph) was rejected as wasteful: most of an iteration's cost is re-reading.
- *Rulings, not stalls*: SP SDD, nearly verbatim in spirit, including the three-part ruling format (decision, why, cost if wrong). This is the right contract for unattended work: a question stops nothing and answers nothing, so decide and make the decision visible.
- *Deferred* and *Stops*: GSD executor deviation rules. Rules 1 to 3 (auto-fix bugs, missing critical functionality, blocking issues *caused by the current task*) become the constitution's scope rule; Rule 4 (architectural change: stop) and the package-install exclusion (a failed install may be a hallucinated or squatted package) become stops; the scope boundary becomes **Deferred**. SP's four stop conditions (irreversible, security-sensitive, outside the worktree, every path a guess) are merged in. "Third failed fix" is SP `systematic-debugging`.
- **Why SP's implementer prompt wasn't the base**: it assumes a controller to ask questions of (`NEEDS_CONTEXT`, "ask them now"). Nobody is there in a Ralph loop.

### `prompts/merge.md`, `prompts/integrate-fix.md`

**New.** MP `implement-spec` has a "merger subagent" with no instructions. The split into two cases is the Brief's point that Git detects textual conflicts but not semantic ones: `merge.md` handles the first, `integrate-fix.md` handles a clean merge that turns the gate red. Both end with an explicit give-up path that parks the slice, so the script never forces a bad merge.

### `templates/state.md`

- **Base idea**: GSD `templates/continue-here.md` (next action, completed, decisions, blockers) and `STATE.md`.
- **Shape**: reduced to what one slice needs. GSD's velocity metrics, progress bars and session-continuity fields are cut. The Brief suggested six files per slice (spec, acceptance, state, decisions, progress, test-results); they are one file with sections here, because a fresh context that must open six files to orient spends its first minutes on that, and the ticket already is the spec and acceptance list.
- **Added from SP**: the rulings section and its line format (machine-collected into the report).
- **Added from SP `verification`**: the evidence column. A criterion is a row with the command and the output line that proves it.

### `hooks/context-guard.sh`, `hooks/hooks.json`

- **Base idea**: GSD `hooks/gsd-context-monitor.js`: a PostToolUse hook that injects a warning at two thresholds, debounced, never blocking, silent on any error.
- **Rewritten (New)**, for one reason: GSD's monitor reads a bridge file written by its *statusline* hook, and a headless `claude -p` run has no statusline, so GSD's monitor is silent in exactly the place this harness needs it. This version reads token usage from the session transcript, which exists in every mode.
- **Thresholds in tokens, not percent**: from MP's "smart zone" (about 150k tokens within which the model still reasons sharply, whatever the window size). On a 1M-token window, GSD's "25% remaining" fires far too late.
- **Two voices**: inside the loop the message is an instruction (checkpoint and end; a fresh context is waiting). Interactively it is advice, because GSD learned (its issue #884, noted in the hook source) that imperative hook messages override what the user wanted.
- **Cut**: GSD's config lookup, the subprocess that records state, and multi-runtime handling. 190 lines of Node became about 35 of bash.

### `skills/tdd/` (3 files)

- **Base**: MP `engineering/tdd`. `tests.md` and `mocking.md` are verbatim. MP's is chosen as the base for three things SP lacks: **seams** agreed in advance, **tautological tests** as a named anti-pattern, and **horizontal slicing** as a named anti-pattern.
- **Added from SP `test-driven-development`**: watch it go red *for the right reason* (fail, not error; missing behaviour, not a typo), watch it go green *pristine*, and "code written before its test is deleted, not adapted". These are SP's real contribution: MP says "red before green" and trusts it; SP specifies what counts as red.
- **Added from SP `writing-good-tests.md`**: "name the break" (the production change that would fail this test) and the change-detector warning. One paragraph from a 198-line file.
- **Added (New)**: the unattended branch of the seam rule. MP says to confirm seams with the user before any test; in the loop there is no user, so the seams come from the spec, and a deviation is a ruling.
- **Changed**: MP says refactoring is not part of the loop and belongs to review; SP has a refactor step every cycle. The rule here: tidy only what this cycle wrote; anything older is a QA matter. That keeps MP's reason (the reviewer sees the whole diff, the implementer is under context pressure) without leaving obvious mess in fresh code.
- **Added from SP**: the "when the test is hard to write" table, four rows.
- **Cut from SP**: the Iron Law block, the eleven-row rationalisation table, the thirteen red flags, the worked examples. They exist to stop an agent arguing its way out of TDD in conversation. Here the loop's structure does that job: the gate and the QA test reviewer check the outcome regardless of what the implementer told itself.

### `skills/debugging/SKILL.md`

- **Base**: MP `engineering/diagnosing-bugs`, kept nearly whole. Its first phase (build a tight, red-capable feedback loop before any theory, with ten ways to construct one) is the strongest single idea on debugging in the sources, and SP's equivalent ("reproduce consistently") is one bullet.
- **Added from SP `systematic-debugging`**:
  - *Mine the differences* (its Phase 2: find a working example, list every difference).
  - *Trace backward to the source* (its `root-cause-tracing.md`, 169 lines with a TypeScript case study, reduced to one paragraph: walk up the call chain to where the value was first wrong; fix there).
  - *Three failed fixes means the design is wrong* (its Phase 4.5). In the loop this is a stop, which bounds how long a slice can thrash.
- **Changed**: MP references a `hitl-loop.template.sh` that does not exist in its repo; the instruction now describes writing such a script, and limits it to when a user is present. The "show hypotheses to the user" checkpoint gains an unattended form (write them to the state file).
- **Cut from SP**: `defense-in-depth.md` (adding validation at every layer after a fix conflicts with the constitution's "one owner per fact" and with the design lens), `condition-based-waiting.md` (a specific technique, not a discipline), the pressure-test files.

### `skills/verification/SKILL.md`

- **Base**: SP `verification-before-completion`: the gate function (identify, run, read, state) and the claim/proof table.
- **Added from GSD `gsd-verifier`**: goal-backward verification. "Task completion ≠ goal achievement", and the three levels (exists, substantive, wired) with stubs as the canonical failure. SP's table says "requirements met needs a line-by-line checklist"; GSD says what to check on each line.
- **Added (New)**: where evidence is recorded (the state file) and the fact that the loop re-runs the gate.
- **Cut from SP**: the rationalisation table and red-flag list, for the same reason as in TDD. GSD's verifier is 917 lines with framework-specific stub patterns; the principle fits in a paragraph.

### `skills/codebase-design/` (3 files)

- **Verbatim** from MP. Referenced by `tdd` (where a seam goes), `slice` (naming modules in **Touches**) and `architecture-survey`. The ARB *A Philosophy of Software Design* rules overlap it; they went into the QA lens instead of being merged here, so the vocabulary stays MP's and the enforcement happens at review.

## QA and human review

### `agents/qa-spec.md`, `qa-tests.md`, `qa-code.md`, `qa-recheck.md`

These are the only agent definitions, and they are split by **axis**, not by role or persona: they have no identity, backstory or seniority, only a question, inputs, and an output format. That is MP's design (`code-review`: "two axes… parallel sub-agents so neither pollutes the other… do not merge or rerank"), extended from two axes to three because the Brief's ten QA questions fall into three groups:

| Brief's question | Axis |
| --- | --- |
| 1 satisfies spec, 2 criteria demonstrably met, 8 silent scope change, 10 matches architectural decisions | spec |
| 3 tests test the requirements, 4 requirements with no test, 5 missing edge cases | tests |
| 6 regressions, 7 accidental complexity, 9 security and data integrity | code |

- **`qa-spec`**. Base: MP `code-review` Spec axis (missing, scope creep, implemented wrongly; quote the spec line). Added from GSD `gsd-verifier`: the adversarial starting hypothesis ("tasks completed, goal missed"), the exists/substantive/wired levels, three verdicts, and "choose FAILED over UNCERTAIN when absence is observable". Added from SP `code-reviewer.md`: "the spec is a vision document" (where the spec is silent, a reasonable user's expectation is the requirement) and the "set aside" list so nothing is dropped silently.
- **`qa-tests`**. New as an axis; no source has a dedicated test audit. Content from MP `tdd` anti-patterns, SP `writing-good-tests` (name the break, change detectors), SP's task reviewer (pristine output; do not re-run the suite, name the test you would run), and GSD's `nyquist-auditor` idea that each requirement needs a test that would catch it breaking.
- **`qa-code`**. Base: MP `code-review` Standards axis, including the twelve-smell Fowler baseline verbatim, the "repo overrides" rule, and "skip what tooling enforces". Added from MP `retro`: the reason standards live here (the reviewer has the least context pressure). Added from SP's task reviewer: look outside the diff only for a risk you can name. Added from the Brief: regressions, safety, accidental complexity. Added from ARB: the lenses (below).
- **`qa-recheck`**. Base: SP `re-review-prompt.md`: verdict each finding, flag breakage in the fix diff only, never widen. Added (New): the `PARKED` verdict for a finding the fixer declined with a ruling, which implements SP's "breaker" adjudication (park contested findings with both sides for the human) without needing a controller to adjudicate.
- **From the Brief, in all four**: reviewers are not shown the implementers' reasoning. The script enforces this by what it passes; the fix notes are shown only to the recheck, as claims to verify (SP: "do not trust the report").
- **From SP, in all four**: read-only, no subagents, the final message is the report, severity calibration.

### `prompts/qa-fix.md`

- **Base**: SP SDD "Final Review" (one fixer with the complete list).
- **Added from SP `receiving-code-review`**: findings are claims to verify against the code before acting, and declining with a reason is legitimate. A 205-line skill reduced to the two sentences that matter here.
- **Added (New)**: the fixed notes format the recheck and the report consume.

### `skills/qa/SKILL.md`

**New**: the same audit dispatched from a session, for branches not built by the loop. Step structure from MP `code-review` (pin the fixed point, find the spec, dispatch, aggregate without reranking). The rule against pre-judging findings in the dispatch prompt is SP's.

### `skills/qa/lenses/` (4 files)

**Verbatim** ARB `mini` rule sets, renamed by purpose. See "agent-rules-books" below.

### `skills/review/SKILL.md`

**New**: the human gate.

- The brief's order (decisions first) is MP `loop-me`'s **brief** concept.
- The four human questions are the Brief's.
- "Feedback is a claim to check" is SP `receiving-code-review`.
- The revise path (new slices appended, re-run) follows from the script's resume design.
- SP `finishing-a-development-branch` (225 lines: merge / PR / keep / discard menus, worktree cleanup) is replaced by "merge the PR, `forge clean`", since delivery is always a PR here.

## Around the flow

### `skills/retro/SKILL.md`

- **Base**: MP `engineering/retro`; categories and the implementation-vs-review reference are his.
- **Added (New)**: the run directory as a primary source, and two categories MP cannot have because he has no loop: **slicing** (stalls and merge collisions point at the slice) and **spec gaps** (clustered rulings name what the spec left out).
- **Adapted**: "where things go" now includes the constitution and the gate.

### `skills/architecture-survey/` (2 files)

- **Verbatim** from MP `improve-codebase-architecture`, renamed, with skill references re-pointed to the `forge:` names. Requested extra.

### `skills/handoff/SKILL.md`, `skills/help/PHASE-BOUNDARIES.md`

- **Verbatim** from MP (`handoff`; `ask-matt/PHASE-BOUNDARIES.md` with the command renamed). This is the context-management guidance for the *interactive* half. The loop has its own; your sessions need a rule for when to continue, clear, hand off, delegate, or compact, and MP's ordered tree is the best statement of it.

### `skills/help/SKILL.md`

- **Base**: MP `ask-matt`, the router pattern: with eleven user-invoked skills, one map is what you remember. Rewritten for this flow, at under half the length.

### `skills/setup/SKILL.md`, `install.sh`, `templates/config.sh`

- **Base idea**: MP `setup-matt-pocock-skills` (run once per repo; configure tracker and labels). Rewritten: the tracker is fixed, so the work is finding the gate command instead.
- **Added (New)**: the skill does everything it can itself and ends with a two-column report, **done for you** and **needs you**, each open item with its exact file or command and an offer to do it. The report shape is MP `loop-me`'s **brief** again: the human is asked once, late, with everything prepared.
- "Find the project's real commands; don't guess" is MP `writing-for-agents`: the environment is the source of truth.
- `config.sh` is plain shell, sourced. GSD's config template has about thirty keys in nested sections; this has ten flat ones.

### `skills/setup/NEW-PROJECT.md`

**New.** A reference file both `/forge:spec` and `/forge:setup` point at, because two user-invoked skills cannot call each other (MP `SKILL-MECHANICS`: shared reference for user-invoked skills lives in a plain file). It creates the repository, installs the Forge files and grants tool permissions, and deliberately nothing else: no scaffold, no installs, no gate. Creating the GitHub repository is the one outward-facing step, so it confirms name and visibility first.

### `scripts/usage-statusline.sh`

**New**, on the pattern of GSD's `gsd-statusline.js` (a status line that writes a bridge file another component reads). About 20 lines against GSD's 537: it records two percentages and prints one line. A `--record-only` mode lets someone keep their own status line.

### `skills/run/SKILL.md`

**New.** The preflight list mirrors what the script would otherwise discover the slow way. "If the run pauses" documents the exit-75 contract.

---

## agent-rules-books: what was used and how

ARB ships 14 rule sets in three sizes. Its own guidance (`docs/USAGE.md`) is: start with one primary set, prefer on-demand loading over always-on, `mini` for a focused task, `nano` only for tight always-on budgets. Its one experiment found concrete rules beat naming the book (74 vs 46 on a judged refactor), with the effect showing in architectural judgement, not smell counts.

Two findings from the other sources decided the placement:

1. MP `retro`: the implementer is under the most context pressure and the reviewer the least, so **standards belong at review**.
2. MP `writing-for-agents`: every always-loaded line costs on every turn, and a rule the model follows anyway is a no-op.

So the books enter in two places.

**`skills/qa/lenses/`: on-demand, at review, full `mini` sets, verbatim.**

| Lens | Book | Loaded |
| --- | --- | --- |
| `design.md` | A Philosophy of Software Design | always. Agents' characteristic failure is shallow modules and pass-through layers; it matches MP `codebase-design`, which the implementers already use; and it is the set ARB actually tested |
| `legacy.md` | Working Effectively with Legacy Code | when the diff changes code that had no tests |
| `data.md` | Designing Data-Intensive Applications | when the diff touches schemas, migrations, events, consistency |
| `reliability.md` | Release It! | when the diff adds calls across a process boundary |

At most two are read per review (ARB: don't stack rule sets). All four are mutually compatible in ARB's own matrix.

**`templates/constitution.md`: always-on for implementers, about 15 rules, distilled.**

| Rule | From |
| --- | --- |
| tracer bullets; one owner per fact | *The Pragmatic Programmer* (mini) |
| separate behaviour and structural changes; refactor what blocks the change, then stop | *Refactoring* (nano) |
| characterization test before changing untested code | *Working Effectively with Legacy Code* |
| deep modules; a wrapper must hide more than it adds; define invalid states away; pull complexity downward | *A Philosophy of Software Design* |
| glossary words for names | MP `domain-modeling` |
| build what the criteria ask for | SP (YAGNI), APoSD |
| scope: fix what you broke, defer the rest | GSD deviation rules |
| ADRs bind; failed install is a stop | MP; GSD |

Each was kept only if an implementer plausibly gets it wrong without it. Phrased as what to do, per MP.

**Not used, and why**

- *Clean Code*: ARB's matrix marks it in tension with APoSD (small functions vs deep modules). One has to win; APoSD matches the rest of the harness.
- *Refactoring*, *Refactoring.Guru*: the QA code reviewer already carries MP's Fowler smell baseline; a second catalogue of the same smells is duplication.
- *Clean Architecture*, *PoEAA*, the three DDD sets: architecture-style commitments. Whether a project is layered, hexagonal, or DDD-tactical is a per-project decision that belongs in that project's ADRs, not in a general harness. The DDD idea that is universal (ubiquitous language) is already here through MP's glossary. Add any of them as a fifth lens file with a trigger line in `qa-code.md` when a project calls for it.
- *Code Complete*: broad construction advice, mostly things current models do unprompted.
- *The Pragmatic Programmer* as a lens: its durable rules are in the constitution; the rest overlaps APoSD at review.
- `full` and `nano` sizes: `full` is reference material for deriving rules; `nano` loses the trigger rules, which are what make a lens useful to a reviewer.

---

## Left out entirely

| Source asset | Why |
| --- | --- |
| SP `using-superpowers` + session-start hook | the always-on bootstrap; explicitly not wanted |
| SP `subagent-driven-development`, `executing-plans`, `writing-plans` | the in-session controller model; replaced by the script. Their best ideas (ledger, rulings, review package, capped fix loops, escalation) were taken |
| SP `dispatching-parallel-agents` | generic advice; parallelism here is the scheduler's |
| SP `using-git-worktrees`, `finishing-a-development-branch` | the script owns worktrees and delivery |
| SP `requesting-code-review`, `receiving-code-review` | folded into the QA agents, `qa-fix.md` and `/forge:review` |
| SP `writing-skills`, `diagnosing-superpowers`, visual companion | about Superpowers itself |
| MP `implement`, `implement-spec` | in-session orchestration; the frontier and integration-branch ideas were taken |
| MP `code-review` | became the QA agents and `/forge:qa` |
| MP `triage`, `wayfinder`, `to-questionnaire`, `wizard`, `teach`, `wait-what`, `pr`, `writing-for-agents` | outside the specified workflow. `writing-for-agents` shaped how everything here is written, and is worth installing separately if you plan to edit these skills |
| GSD's 33 agents, 67 commands, SDK, installer, `.planning/` tree | role-based, process-owning; its ideas were taken (state file, context monitor, deviation rules, goal-backward verification, overlap check, requirement IDs) and nothing else |
| GSD statusline, update checker, prompt-injection scanners, commit validators | product infrastructure |
| The Brief's seven-directory memory tree | mapped onto locations that already had owners (`GLOSSARY.md`, `docs/adr/`, issues, `.forge/`) instead of adding `architecture/`, `domain/`, `specs/`, `decisions/`, `tasks/`, `state/` directories. Same layers, fewer places |
