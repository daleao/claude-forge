---
name: qa
description: The Forge QA audit, run by hand on any branch. Three independent reviewers (spec, tests, code) in parallel, findings reported side by side.
argument-hint: "A fixed point to diff against (branch, tag, SHA), and optionally a spec issue"
disable-model-invocation: true
---

Audit the diff between `HEAD` and a fixed point along three axes, each in its own subagent so none colours the others. This is the same audit `forge run` performs at the end of a build; use this skill for a branch built by hand, or to re-audit after changes.

For a spec built by the loop, prefer `forge qa <spec>` from a terminal: it also runs the bounded fix rounds and updates the PR.

## 1. Pin the inputs

- **Fixed point**: whatever the user named. Confirm it resolves (`git rev-parse`) and the diff is non-empty before going further.
- **Spec**: an issue number the user passed, else issue references in the commit messages. With no spec, skip the spec axis and say so in the report.
- **Audit directory**: `.forge/qa/<fixed>..<head>/` in the project, named with the two short SHAs. If `.forge/.gitignore` does not list `qa/`, add that line (create the file if it is missing), so nothing here is committed. If the directory already holds files from an earlier attempt at this same audit, keep them: they are the checkpoint.
- Write these files there, so the reviewers read files and nothing lands in your context. Skip one that already exists:
  - `diff.patch`: `git log --oneline <fixed>...HEAD`, `git diff --stat <fixed>...HEAD`, then `git diff -U10 <fixed>...HEAD` with lock files left out (`-- . ':(exclude,glob)**/<name>'` for each lock file the stat shows, such as `pnpm-lock.yaml` or `Cargo.lock`) and, above the diff, a line naming the files left out
  - `spec.md` and `slices.md`: issue bodies via `forge issue view <n>`, which prints the body and never the comments
  - `gate.log`: the output of the project's verify command, run now

## 2. Dispatch the three reviewers in parallel

Dispatch `forge:qa-spec`, `forge:qa-tests` and `forge:qa-code` as subagents in one message, leaving out any axis whose report is already in the audit directory. Each prompt carries only paths: the files from step 1, `.forge/constitution.md`, and the lens directory, which is `lenses/` beside this file.

Give them the files and nothing else. Your own view of what the branch does, or which findings would be false alarms, stays out of the prompts: a reviewer told what to expect finds it.

As each reviewer returns, save its report verbatim to `spec-axis.md`, `tests-axis.md` or `code-axis.md` in the audit directory, before doing anything else with it. If the session ends early, running this skill again on the same two commits dispatches only the reviewers whose reports are missing.

## 3. Report

Present the three reports under `## Spec`, `## Tests` and `## Code`, verbatim. Keep the axes separate: a branch can implement the right thing badly or the wrong thing well, and a merged ranking hides which. Close with one line per axis: the count of `[BLOCKER]` and `[IMPORTANT]` findings and the worst one.

## 4. Fix rounds, if the user wants them

Offer to fix the blocking findings. If the user agrees:

1. Write the blocking findings to `findings.md` in the audit directory. One subagent gets the whole findings list, with the instructions in `prompts/qa-fix.md` at the plugin root. One fixer for the list, never one per finding.
2. Run the verify command, then dispatch `forge:qa-recheck` with the findings, the fix notes, and the fix diff. The notes, the fix diff and the recheck's report go in the audit directory too, numbered by round.
3. Two rounds at most. What is still open, and anything the recheck parked, goes to the user with both sides stated.
