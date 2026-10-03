---
name: tdd
description: Test-driven development. Use when building a feature or fixing a bug test-first, when the user mentions "red-green-refactor", or when a loop iteration implements a slice.
---

# Test-Driven Development

TDD is the red → green loop. This skill is the reference that makes that loop produce tests worth keeping: what a good test is, where tests go, the anti-patterns, and the rules of the loop. Every section applies on every cycle: consult them before and during the loop, not after.

When exploring the codebase, read `GLOSSARY.md` (if it exists) so test names and interface vocabulary match the project's domain language, and respect ADRs in the area you're touching.

## What a good test is

Tests verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't. A good test reads like a specification: "user can checkout with valid cart" tells you exactly what capability exists, and it survives refactors because it doesn't care about internal structure.

Before writing a test body, **name the break**: the production change that would make this test fail. A test that only an intentional redesign could fail (a constant's value, exact wording, private structure) is a change detector; test the behaviour that depends on the decision instead.

See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.

## Seams: where tests go

A **seam** is the public boundary you test at: the interface where you observe behavior without reaching inside. Tests live at seams, never against internals.

**Test only at agreed seams.** You can't test everything, so agreeing the seams up front is how testing effort lands on the critical paths and complex logic instead of every edge case.

- **With a user present**: write down the seams under test and confirm them before the first test. Ask: "What's the public interface, and which seams should we test?"
- **Unattended (a loop iteration)**: the seams are the ones the spec's "Seams and testing decisions" section names. When a criterion can't be reached through any of them, take the highest existing seam that reaches it and record the choice as a **ruling** in the slice's state file.

When the shape of that interface is itself in question (how deep the module is, where the seam belongs, what the interface should expose), call the Skill tool with "forge:codebase-design" for the vocabulary. It is a reference to consult, not a session to run.

## Anti-patterns

- **Implementation-coupled**: mocks internal collaborators, tests private methods, or verifies through a side channel (querying the database instead of using the interface). The tell: the test breaks when you refactor but behavior hasn't changed.
- **Tautological**: the assertion recomputes the expected value the way the code does (`expect(add(a, b)).toBe(a + b)`, a snapshot derived by hand the same way, a constant asserted equal to itself), so it passes by construction and can never disagree with the code. Expected values must come from an independent source of truth: a known-good literal, a worked example, the spec.
- **Horizontal slicing**: writing all tests first, then all implementation. Bulk tests verify _imagined_ behavior: you test the _shape_ of things rather than user-facing behavior, the tests go insensitive to real changes, and you commit to test structure before understanding the implementation. Work in **vertical slices** instead: one test → one implementation → repeat, each test a **tracer bullet** that responds to what the last cycle taught you.

## Rules of the loop

- **Red before green.** Write the failing test first, then only enough code to pass it. Don't anticipate future tests or add speculative features.
- **Watch it go red, for the right reason.** Run the test before writing the code. It must _fail_ (not error), and fail because the behaviour is missing, not because of a typo or a broken import. A test that passes on first run is testing behaviour that already exists: fix the test. A test you never saw red has never proven it can catch anything.
- **Watch it go green, pristine.** Run it again after the code. Green means this test passes, the tests around it still pass, and the output carries no new warnings or errors.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **Code written before its test is deleted, not adapted.** Keeping it "as reference" means writing the test to fit the code. Delete it and let the test drive it back.
- **Tidy only what this cycle wrote.** While green, rename and de-duplicate inside the code the cycle just added. Restructuring anything older belongs to the review stage, where it is weighed against the whole diff.

## When the test is hard to write

| Symptom | What it's telling you |
| --- | --- |
| Don't know how to test it | Write the call you wish existed, then the assertion, then make them real. |
| Test needs a mock for everything | The code is too coupled; inject the dependency at the seam. |
| Setup dwarfs the assertion | The interface is too wide; simplify it before testing it. |
| The seam can't reach the behaviour | A design finding. With a user, raise it; unattended, record a ruling. |
