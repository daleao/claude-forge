---
name: slice
description: Step 3 of the Forge pipeline. Break a spec into vertical slices with blocking edges, published as GitHub issues the loop can run in parallel.
argument-hint: "The spec issue number"
disable-model-invocation: true
---

Break the spec into **slices**: tracer-bullet vertical slices, each declaring the slices that **block** it. Together they form a task graph, and the loop works its **frontier**: every slice whose blockers have merged.

## 1. Gather context

Work from the conversation. If the user passed a spec issue number that isn't in context, fetch it with `forge issue view <n>`. If you haven't explored the codebase, do so; use `GLOSSARY.md` vocabulary and respect ADRs.

Look for prefactoring that would make the build easier: make the change easy, then make the easy change.

## 2. Draft the slices

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests): vertical, never one horizontal layer
- A merged slice is demoable or verifiable on its own
- Each slice fits in a single fresh context window; the loop gives it several, but a slice that needs them is a slice to split
- Prefactoring comes first, as its own slice

</vertical-slice-rules>

Give each slice three things beyond its description:

- **Blocked by**: the slices that must merge before it can start. Only real gates: an edge that isn't needed costs parallelism.
- **Covers**: the spec's `AC-n` IDs this slice delivers.
- **Touches**: the modules it will change, named in glossary and `forge:codebase-design` terms. The loop never runs two slices with a shared **Touches** entry at the same time, so this is how you keep **write sets** apart. Two slices that touch the same module and also depend on each other's behaviour need a blocking edge, not just a shared entry.

**A new project starts with a foundation slice.** When the spec has a "Project foundation" section, the first slice builds exactly that and nothing else: the scaffold, the checks wired into the gate command, and one **tracer test** that runs through the real entry point (a request to a health route, a CLI invocation that prints its version). Its acceptance criteria are: the scaffold matches the spec's "Project foundation" section; `FORGE_VERIFY_CMD` and `FORGE_SETUP_CMD` in `.forge/config.sh` are set to the spec's gate and setup commands, verbatim; that gate exits 0; and the tracer test passes through the agreed seam. The gate is defined here, with the scaffold, because it depends on the stack the spec chose. Mark it with a `## Foundation` heading in its body, as shown in the template. The loop then knows the gate cannot pass before this slice merges, runs it alone, and holds every other slice until it has. Keep features out of it: a foundation that also delivers behaviour is two slices.

**Wide refactors are the exception to vertical slicing.** A wide refactor is one mechanical change (rename a column, retype a shared symbol) whose blast radius fans across the codebase, so no vertical slice can land green. Sequence it as **expand–contract**: a slice that adds the new form beside the old; migrate slices batched by blast radius (per package, per directory), each blocked by the expand; a final contract slice that deletes the old form, blocked by every migrate batch.

## 3. Check coverage

Before showing the user anything, build the table: every `AC-n` in the spec against the slices that cover it. An AC with no slice is a hole in the plan; a slice that covers no AC is scope the spec never asked for. Fix both, or raise them in the next step.

## 4. Quiz the user

Present the breakdown as a numbered list (title, blocked by, covers, touches, what it delivers) followed by the order the loop will run it in: group the slices into the waves the blocking edges allow, so the user can see what runs in parallel.

Ask:

- Does the granularity feel right?
- Is each blocking edge a real gate?
- Should any slices be merged or split?

Iterate until the user approves.

## 5. Publish

Create one issue per slice in dependency order (blockers first), so each **Blocked by** can cite real issue numbers:

```bash
forge issue create slice --title "<slice title>" --body-file <slice body>
```

Then append the slice list to the spec issue's body. This list is how the loop knows which slices belong to the spec:

```md
## Slices
- [ ] #<n> <slice title>
- [ ] #<n> <slice title>
```

```bash
forge issue edit <spec> --body-file <spec body with the Slices section appended>
```

Tell the user the next step: `forge run <spec>` from a terminal, or `/forge:run <spec>`.

<slice-template>

## Parent

#<spec issue>

## What to build

The end-to-end behaviour this slice makes work, from the user's perspective. Not a layer-by-layer task list.

## Acceptance criteria

- [ ] AC-<n>: <copied from the spec>
- [ ] <any slice-local criterion, same observable form>

## Verify

How to demonstrate the slice once merged: a command, or a behaviour to observe.

## Blocked by

- #<issue>, or "None"

## Touches

- <module>

## Foundation

(Foundation slice only; omit this heading everywhere else.) This slice builds the project scaffold and makes the gate pass for the first time.

</slice-template>

Keep the headings exactly as written; the loop script parses `## Blocked by`, `## Touches` and `## Foundation`. Leave file paths and code out of slice bodies, they go stale; the prototype-snippet exception from `/forge:spec` applies here too.
