---
name: spec
description: Step 2 of the Forge pipeline. Turn the grilled conversation into a spec sized to the work, and publish it as a GitHub issue.
disable-model-invocation: true
---

Turn the current conversation and your understanding of the codebase into a **spec**. Do not interview the user again; synthesise what is already settled. If the conversation left an **unknown** open, name it and send the user back to `/forge:grill` for that branch.

## 1. Size the work, out loud

Pick a tier and say which one and why, so the user can override it before you write anything:

| Tier | The work is… | You write |
| --- | --- | --- |
| **Small** | a well-scoped change to a flow that already exists in this repo | acceptance criteria only, as a single slice issue (skip to step 5) |
| **Medium** | one feature, existing architecture | FDD |
| **Large** | a new capability, several user-facing behaviours | PRD + FDD |
| **Architectural** | new subsystem, or a change to how modules fit together | PRD + FDD + an ADR per hard-to-reverse decision |

In doubt between two tiers, take the heavier. The ratchet is one-way: complexity discovered later upgrades the tier, nothing downgrades it.

**A new project** (no code in the folder yet) is at least **Large**, and its FDD carries a "Project foundation" section (see the templates). There is no codebase to explore and no existing seam to prefer in step 2: name the seam the foundation will create (the HTTP layer, the CLI entry point, the public module) and agree that.

## 2. Explore and agree the seams

Explore the repo if you haven't. Use `GLOSSARY.md` vocabulary throughout, and treat ADRs in the area as binding.

Sketch the **seams** the feature will be tested at. Prefer existing seams to new ones and the highest seam that reaches the behaviour; the ideal number is one. Confirm the seams with the user: the implementation loop runs unattended and tests only at seams this spec names.

## 3. Write it

Use the templates in [TEMPLATES.md](TEMPLATES.md). Two rules bind every tier:

- **Acceptance criteria are numbered and observable.** `AC-1`, `AC-2`, … each one a behaviour someone could watch pass or fail from outside the code. Slices, tests and the QA audit all trace back to these IDs.
- **Decisions, not file paths.** Name modules and interfaces; leave paths and code out, they go stale. The exception is a snippet from a prototype that encodes a decision more precisely than prose (a state machine, a schema, a type shape): inline the decision-rich part and say it came from a prototype.

For the **Architectural** tier, call the Skill tool with "forge:domain-modeling" and record each qualifying decision as an ADR before publishing; the spec links them.

## 4. Self-review

Read the draft once as its implementer would, and fix what you find inline:

- **Placeholders**: any TBD, TODO, or "handle appropriately".
- **Contradictions**: sections that disagree, a design that doesn't deliver a stated AC.
- **Ambiguity**: any requirement two engineers would build differently. Pick one reading and write it down.
- **Scope**: anything in the design that no AC asks for. Cut it or add the AC.

## 5. Approve, then publish

Show the user the draft and wait for an explicit yes. An approval of the idea is not an approval of the document.

Publishing needs a GitHub repository to hold the issue. If this folder isn't one yet (`git remote get-url origin` fails), read [NEW-PROJECT.md](../setup/NEW-PROJECT.md) and follow it now, with the approved draft in hand: it creates the repository, installs the Forge files, and grants the foundation slice the tools the spec's "Project foundation" section calls for. It scaffolds nothing and defines no gate; the foundation slice does both.

Then publish:

```bash
forge issue create spec --title "<feature name>" --body-file <draft>
```

For the **Small** tier there is no spec issue: publish one issue with `forge issue create slice`, using the slice template from the `/forge:slice` skill, and tell the user it can go straight to `forge run <issue>`.

Otherwise report the issue number and tell the user the next step is `/forge:slice <issue>`, in this same session.
