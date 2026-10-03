---
name: grill
description: Step 1 of the Forge pipeline. A relentless interview that sharpens an idea, building the glossary and ADRs as it goes.
argument-hint: "The idea, in a sentence or a paragraph"
disable-model-invocation: true
---

Call the Skill tool twice, for "forge:grilling" and "forge:domain-modeling", and run them together on the user's idea: the interview resolves the design tree, and every term or hard-to-reverse decision that crystallises is written to `GLOSSARY.md` or `docs/adr/` the moment it does.

**A new project** (the folder has no code yet, or isn't a repository at all) needs nothing set up first: the interview works in an empty folder. Its design tree gains one branch, the **project foundation**: language and runtime, framework, package manager, test runner, typechecker and linter, where it will be deployed, and the directory layout. Most of these are defaults you choose to fit the idea; ask only about the ones the user is likely to hold a view on. Nothing is scaffolded during the interview: the foundation is built later, from the approved spec, as the first slice of the unattended run.

Two detours leave the interview and come back:

- An **unknown** that reading can settle (a library's behaviour, an API's limits, prior art): call the Skill tool with "forge:research". It runs in the background; keep grilling the branches that don't depend on it.
- An **unknown** that only running code can settle (does this state model feel right, what should this look like): call the Skill tool with "forge:prototype" once the user agrees to the detour.

When the user confirms the closing understanding, stay in this session and tell them the next step is `/forge:spec`: the spec is written from this conversation, so it must still be in context.
