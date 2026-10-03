---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

## Scope first

Before the first round, size the idea. If it describes several independent subsystems ("a platform with chat, billing and analytics"), say so and split it into sub-projects with the user: what the independent pieces are, how they relate, which comes first. Then grill the first sub-project only. Each sub-project gets its own tree, spec and build.

## Rounds

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

When a question has genuinely different ways to go (an approach, an architecture, a data model), lay out the two or three real alternatives with the trade-off each one buys, then recommend one. Cut every option down to what the stated goal needs: an alternative that only adds features nobody asked for is not an alternative.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

## What earns a question

The user's attention is the scarce resource in this session. Every decision on the frontier gets resolved, but only some are resolved by asking. A decision **earns a question** when both hold:

- **It changes what gets built**: two reasonable answers lead to different behaviour, scope, or structure.
- **You can't settle it yourself**: it turns on the user's intent, taste, priorities, or knowledge of their users or business, and getting it wrong would be costly to undo.

Everything else is a **default**: decide it yourself and move on. That covers anything with one sensible answer, anything the codebase, `GLOSSARY.md`, an ADR, or an earlier answer already settles, anything the user's stated goal implies, and any detail that is cheap to change later (a label, a default value, a file name).

Close each round with the defaults you took since the last one, one line each, so the user can overturn any of them without being asked about all of them:

```
**Defaults I chose** (say the number to change one)
D1. <decision> — <one-line reason>
D2. <decision> — <one-line reason>
```

A default the user overturns becomes a settled decision like any other, and may reopen the branches below it.

Before sending a round, test each question: if you would be surprised by any answer other than your recommendation, it is a default, not a question.

## Facts and decisions

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ that earn a question are the user's: put each to them and wait.

## Done

The session is done when the frontier is empty: every branch of the design tree resolved, by an answer or by a listed default, nothing left silently assumed. The user can also end it at any point; whatever is still open then goes into the write-back as **assumed**. Close by writing back the understanding in six short lists, marking each line as **said** (the user stated it or accepted it as a listed default) or **assumed** (you inferred it and never showed it to them):

- **Problem**: what is wrong today, and for whom
- **Goals**: what success looks like, observably
- **Non-goals**: what this deliberately leaves out
- **Constraints**: what the solution must respect
- **Decisions**: each settled branch, one line
- **Unknowns**: what is still open, and what would settle it (research, a prototype, another person)

Every **assumed** line is a question you still owe: ask it. Do not act on the understanding until the user confirms it.
