---
name: verification
description: Evidence before claims. Use before stating that work is complete, fixed, or passing; before setting a slice to done; before committing a fix or opening a PR.
---

# Verification

A claim of success is a claim about a command's output. Until you have run the command and read the output in this turn, you have a belief, not a result.

## The gate

Before any statement that work is done, fixed, passing, or ready:

1. **Identify** the command that proves the claim.
2. **Run** it, fresh and in full.
3. **Read** the whole output: exit code, failure count, warnings.
4. **State** what the output shows, with the evidence. If it contradicts the claim, the claim changes.

| Claim | What proves it | What does not |
| --- | --- | --- |
| Tests pass | the test command's output, 0 failures, this turn | an earlier run; "should pass" |
| Build succeeds | the build command, exit 0 | the linter passing |
| Bug fixed | the original symptom's repro goes green | the code changed |
| Regression test works | you saw it red without the fix and green with it | it passes once |
| Criterion met | the behaviour observed through the interface | the tests passing |
| Subagent finished | the diff it produced | its report |

The words "should", "probably" and "seems to" in a status line mean the gate was skipped. Go back to step 1.

## Goal-backward: tasks done is not goal achieved

A task "add the import endpoint" is complete when a file exists; the criterion "a user can import a CSV" is met only when it works end to end. For each acceptance criterion, check three levels, in order:

1. **Exists**: the code the criterion needs is there.
2. **Substantive**: it is a real implementation. A handler that returns a constant, a component that renders a placeholder, a function whose body is a TODO: these exist and prove nothing.
3. **Wired**: something calls it. The route is registered, the component is mounted, the job is scheduled, the result reaches the caller. Unwired code passes its own tests and delivers no behaviour.

A criterion is verified when all three hold and a test at an agreed seam watched the behaviour happen.

## Recording evidence

In a loop iteration, evidence goes in the slice's state file, one row per criterion: the command you ran and the line of output that proves it. A row marked done with no evidence is an unverified claim, and the QA audit treats it as one.

Before setting `Status: done`, run the project's full verify command. The loop runs the same command itself straight afterwards and reopens the slice if it fails, so a premature done only costs an iteration.
