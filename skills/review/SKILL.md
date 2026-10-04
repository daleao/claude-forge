---
name: review
description: Step 5 of the Forge pipeline. Walk the human through the finished run's report and PR, then merge or revise.
argument-hint: "The spec issue number"
disable-model-invocation: true
---

The build ran unattended; this is where the human takes it back. Your job is to make their review fast: lead with what needs a decision, keep the evidence one step behind it.

## 1. Cleanup first

Before the brief, tell the user what the run left on their machine. Read `.forge/runs/<spec>/cleanup-registry.md` (the last `## Cleanup pass` section) and `.forge/runs/<spec>/cleanup-manual.md`, and report in a few lines:

- what the cleanup pass removed on its own
- how many steps it left for a person, and what they are (a line each: the item, and why it was not automatic)
- what stays on purpose until the PR is merged: the worktrees, the branches, the run directory

If steps are open, remind the user that they are theirs to do and that `/forge:cleanup <spec>` walks through them one at a time. They can do it now or after the review; do not start it yourself. If the registry has no cleanup pass, or the last one is marked `INCOMPLETE`, say that nothing has been checked and that `forge cleanup <spec>` runs the pass.

## 2. Brief

Read `.forge/runs/<spec>/qa/report.md` and the PR (`forge pr view <spec>`). Present a brief, in this order, each item one or two lines with a pointer to where the detail lives:

1. **What was built**: the acceptance criteria and their verdicts from the spec axis.
2. **Slices that did not merge**, and why.
3. **Findings still open** after the fix rounds, and **findings the fixer declined**, with both sides.
4. **Rulings**: every decision an agent made on the user's behalf, with what it costs if wrong. These are the decisions most likely to need reversing; give each its own line.
5. **Deferred** and **minor** items, as a count with a pointer.

Then ask the user for a decision on every item under 2 to 4, one round, numbered, each with your recommendation.

## 3. The questions only a human can answer

Once the listed items are settled, put these to the user. The audit cannot answer them:

- Is this what you wanted?
- Is the product behaviour right when you use it? (Offer the `## Verify` steps from the slices so they can try it.)
- Are the architectural trade-offs acceptable?
- Would you be content to maintain this?

## 4. Act on the answers

Feedback is a claim to check, not an order to carry out. For each change the user asks for: restate it, check it against the code, and if it would break something or contradict the spec, say so with the evidence before doing anything.

- **Small corrections** (a reversed ruling, a rename, a missed case): fix them here on the integration branch. Call the Skill tool with "forge:tdd", then "forge:verification" before saying it is done. Push with `forge pr push <spec>`.
- **Larger rework or a missing behaviour**: write it as new slice issues with the `/forge:slice` template, append them to the spec's `## Slices` list, and tell the user to run `forge run <spec>` again. Merged slices are kept; only the new ones run, followed by a fresh QA pass.
- **A parked slice**: follow "If a slice is parked" in `/forge:run`.
- **The spec itself was wrong**: that is a new idea. Back to `/forge:grill`.

## 5. Merge

When the user approves, they merge the PR; the `Closes` lines resolve the spec and slice issues. Then:

```bash
forge clean <spec>
```

If `cleanup-manual.md` still has steps marked `Status: open`, say so again here: `/forge:cleanup <spec>`.

Suggest `/forge:retro` while the run's logs are fresh, especially if slices were parked or QA needed both fix rounds.
