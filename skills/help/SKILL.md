---
name: help
description: Which Forge skill or step fits your situation. A map of the pipeline and everything around it.
disable-model-invocation: true
---

# Forge: the map

Answer the user's question about what to do next from this map. If they asked nothing specific, show the main flow and ask where they are in it.

## The main flow: idea → merged

| # | Step | You | The agent |
| --- | --- | --- | --- |
| 1 | **`/forge:grill`** | answer rounds of questions | maps the design tree, records glossary terms and ADRs |
| 2 | **`/forge:spec`** | approve the tier and the draft | writes PRD/FDD sized to the work, publishes the spec issue |
| 3 | **`/forge:slice <spec>`** | approve the breakdown | cuts vertical slices with blocking edges, publishes slice issues |
| 4 | **`forge run <spec>`** (or `/forge:run`) | walk away | builds each slice test-first in a fresh-context loop, merges, audits, fixes, opens the PR |
| 5 | **`/forge:review <spec>`** | decide | briefs you on rulings, open findings and parked slices; merges or revises |

Steps 1 to 3 belong in **one unbroken session**: the spec is written from the grilling, the slices from the spec, and a summary of either loses the reasoning. Step 4 runs outside any session. Step 5 can be a fresh session; everything it needs is in the report.

A change small enough to need no spec skips to one slice issue (`/forge:spec` decides this out loud) and `forge run <issue>`.

**Starting from an empty folder** uses the same five steps, with no setup first. The interview also settles the stack; `/forge:spec` creates the repository and config when it is ready to publish; `/forge:slice` makes the first slice a **foundation slice**; and `forge run` builds that scaffold first, alone, before any feature.

If `forge run` stops with `paused:` (exit status 75), it hit a usage limit or a failed agent call. Nothing is lost; run it again later.

## The same flow, as a class

**`/forge:teach <idea>`** runs all five steps attended, in the session, with the agent as teacher and you as student. It makes the technical decisions and teaches each one, builds a few lines at a time, and checks your understanding before moving on. Nothing runs unattended and no issues are published; the course lives in `.forge/class/<course>/`. Run `/forge:teach` with no argument to resume. Pick it when the aim is to understand the project, not to get it built quickly.

## Detours from the main flow

- **`forge:research`**: a question that reading can settle. Runs as a background agent, leaves cited notes in the repo. Reach for it during the grilling.
- **`forge:prototype`**: a question only running code can settle (does this state model hold, what should this look like). Throwaway code; the answer goes into the spec.
- **`forge:debugging`**: something is broken and resists a first look. Builds a feedback loop that goes red on the bug before theorising. The build loop uses it on its own; reach for it directly for bugs outside a run.

## Around the flow

- **`/forge:retro <spec>`**: after a run, turn its stalls, rulings and QA findings into changes to the agents' environment: checks, standards, slicing habits.
- **`/forge:architecture-survey`**: upkeep. Surveys the codebase for deepening opportunities and hands you candidates; picking one gives you an idea for step 1.
- **`/forge:cleanup <spec>`**: after a run, go through what it left on your machine that the cleanup pass would not remove on its own, one step at a time.
- **`/forge:qa <fixed point>`**: the QA audit by hand, on any branch.
- **`/forge:handoff`**: write a portable summary when work has to travel to another harness, repo, or person.
- **`/forge:setup`**: once per repo, before the first run.

## Underneath

Model-invoked references the steps above pull in. Reach for one directly when it is the thing you need:

- **`forge:grilling`**: the interview primitive (rounds, the frontier, facts are the agent's job and decisions are yours).
- **`forge:domain-modeling`**: sharpen the domain language; keeps `GLOSSARY.md` and `docs/adr/`.
- **`forge:codebase-design`**: the deep-module vocabulary (module, interface, depth, seam, adapter, leverage, locality).
- **`forge:tdd`**: the red → green loop and what makes a test worth keeping.
- **`forge:verification`**: evidence before claims; exists → substantive → wired.

## Where things live

| What | Where |
| --- | --- |
| Engineering rules | `.forge/constitution.md` |
| Domain language, decisions | `GLOSSARY.md`, `docs/adr/` |
| Specs and slices | GitHub issues labelled `forge:spec`, `forge:slice` |
| Run state (ledger, per-slice memory, logs, QA report) | `.forge/runs/<spec>/`, git-ignored |
| What a run left on the machine, and what is left for you to remove | `.forge/runs/<spec>/cleanup-registry.md`, `cleanup-manual.md` |
| Worktrees | `.forge/worktrees/<spec>/`, git-ignored |
| Config (gate command, models, limits) | `.forge/config.sh` |
| A class: notebook, glossary, spec, slices, audit report | `.forge/class/<course>/`, committed |

## Context, in interactive sessions

The build loop manages its own context: each iteration is a fresh window, and a guard tells it to checkpoint before the window fills. In your own sessions the decision is yours, and it belongs at a **phase boundary**, the moment you think "ok, we're done with that". Read [PHASE-BOUNDARIES.md](PHASE-BOUNDARIES.md) for the ordered tree: continue, `/clear`, `/forge:handoff`, a subagent, or `/compact`.
