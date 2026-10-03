---
name: retro
description: Conduct a retrospective on a Forge run or a coding session, and suggest improvements to the agents' environment.
argument-hint: "A spec issue number, or nothing for the current session"
disable-model-invocation: true
---

The user has asked for a **retrospective**. You are suggesting improvements to the coding agents' **environment** to improve future runs. The code is not the subject; what the agents had to work with is.

## Steps

1. Read the primary sources.
   - **For a Forge run** (the user gave a spec number), everything is under `.forge/runs/<spec>/`: `ledger.md` (the timeline: stalls, escalations, parks), each slice's `state.md` (rulings, deferred items, gate failures) and `iter-*.log`, and `qa/report.md` with the fix-round notes. Start from the ledger and read the logs of the slices that needed the most iterations.
   - **For an interactive session**, the session's own log on this machine; default to the current session.

2. Look for candidates for improvement in these categories.

- **Navigation**: how easy was it for the agent to find the right files? Are there hidden dependencies between files? Would a **navigation pointer** make it easier? _Use when_ an iteration spent a long time finding a piece of information, or several iterations re-found the same thing.
- **Automated checks**: are there checks that could catch errors the agent made? Linting, typing, tests, filesystem linters? Read the repo's own check command first (its build-tool scripts, its CI workflow, `FORGE_VERIFY_CMD`), so a check that already exists but sits unwired is the finding, not a reinvention. Every QA finding that a deterministic check could have caught is a candidate to add to the gate. _Use when_ the agent made a mistake an automated check could have caught.
- **Coding standards**: should the QA code reviewer be given a new rule? Classify the violation first: a **mechanical** one (a fixed syntactic pattern, a banned API, an import shape, a file-location rule) gets a deterministic check, full stop. Reserve `.forge/constitution.md` and `CODING_STANDARDS.md` for genuine **judgement calls**. _Use when_ QA missed something the human caught at review.
- **Slicing**: did a slice stall, need many iterations, or collide with a sibling at merge? That points at the slice: too large, a missing blocking edge, an incomplete **Touches** list. Feed the pattern back as a rule the user applies at the next `/forge:slice`.
- **Spec gaps**: read the rulings. A ruling is a question the spec left open. Rulings that cluster (the same kind of question, slice after slice) name a section the next spec should not leave out.
- **Constitution and steering files**: are there instructions that changed nothing (**no-ops**), or that belong in a check instead? _Use when_ those files are growing.
- **Tool economy**: did agents make expensive tool calls that could be streamlined? Is any custom tooling token-heavy? Was the gate slow enough to dominate iterations?
- **Information access**: what did an agent need and not have? Dev-server logs, read-only access to a third-party service, a tool missing from `FORGE_ALLOWED_TOOLS` (look for denied commands in the iteration logs).

3. Present the candidates to the user, most severe first, each with the evidence (file and line in the run's records) and the concrete change you propose. Make the changes the user approves.

## Reference

### Implementation vs review

All work goes through two stages. The implementing agent has the most **context pressure**: it explores, writes, and debugs. The reviewing agent has the least: it receives a diff. So standards are imposed at review, and the implementer's always-loaded context (the constitution) stays small.

### Where things go

- `CLAUDE.md`: pushed into every agent's context. Use it sparingly, mostly for **navigation pointers**.
- `.forge/constitution.md`: read at the start of every loop iteration. Judgement-call rules implementers get wrong without it; nothing else.
- `CODING_STANDARDS.md`: read by the QA code reviewer only. The home for standards.
- The gate (`FORGE_VERIFY_CMD`), linters, CI: the home for anything mechanical.
- Docs: reference files, reached by a pointer. Look for an existing doc before writing a new one.
