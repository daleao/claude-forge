# Spec templates

One GitHub issue holds the whole spec. A **Large** or **Architectural** spec is the PRD part followed by the FDD part in the same body; a **Medium** spec is the FDD part with a two-line Problem on top.

Keep the section headings exactly as written: the loop script and the QA reviewers find sections by heading.

## PRD part: what the product should do

```md
# PRD

## Problem
The problem the user faces, from the user's perspective.

## Solution
What changes for the user once this ships, from the user's perspective.

## User stories
A long numbered list covering every aspect of the feature:
1. As a <actor>, I want <feature>, so that <benefit>

## Acceptance criteria
- **AC-1**: <observable behaviour, pass/fail from outside the code>
- **AC-2**: ...

## Non-goals
What this spec deliberately leaves out.
```

## FDD part: how the feature behaves technically

```md
# FDD

## Problem
(Medium tier only, two lines. Large tiers already have it in the PRD.)

## Project foundation
(New projects only. What the first slice of the run will build, before any feature.)
- **Stack**: language and runtime version, framework, package manager
- **Layout**: the top-level directories and what each holds
- **Checks**: test runner, typechecker, linter/formatter
- **Gate command**: the one command line that runs all the checks and exits 0 only when every one passes. The foundation slice writes it into `.forge/config.sh` as `FORGE_VERIFY_CMD`.
- **Setup command**: what a fresh checkout runs before the gate can work (install dependencies). The foundation slice writes it as `FORGE_SETUP_CMD`.
- **Dependencies**: each package the foundation installs, by exact name. The run installs nothing this list doesn't name.

## Implementation decisions
The decisions already made, each one line with its reason:
- modules built or modified, and the interface each presents
- schema changes, API contracts, specific interactions
- architectural decisions, linking any ADR (`docs/adr/NNNN-slug.md`)

## Seams and testing decisions
- the seams the feature is tested at, as agreed with the user
- what a good test looks like here (external behaviour only)
- prior art: similar tests already in the codebase

## Failure modes
How the feature behaves when its inputs, dependencies or environment misbehave. Each one either maps to an AC or is declared out of scope.

## Acceptance criteria
(Medium tier only. Same numbered, observable form as the PRD.)

## Out of scope
Technical work this spec does not include.

## Notes
Anything else an implementer with no access to this conversation needs.
```

The `## Slices` section is appended later by `/forge:slice`. Leave it out here.
