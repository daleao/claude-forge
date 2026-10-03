# Constitution

Engineering rules for every agent working in this repo. Each loop iteration reads this first. Keep it short: a rule earns its line only if agents get it wrong without it. Mechanical rules belong in a linter, not here.

## Shape of the work

- Build **tracer bullets**: a thin path through every layer that really runs, then widen it. A finished layer with nothing calling it is not progress.
- Keep behaviour changes and structural changes in separate commits. Each commit builds and passes its tests.
- Refactor the thing that blocks the current change, and stop when the change is easy.
- Changing code with no trustworthy tests: first pin its current behaviour with a characterization test at the nearest seam, then change it.

## Shape of the code

- Prefer **deep modules**: a small interface hiding real complexity. A new wrapper, layer, flag, or option has to hide more than it adds.
- Each fact has one owner. A rule, mapping, or schema stated in two places is derived from one of them, not typed twice.
- Callers get a simple contract; the module that owns a detail absorbs its mess. Define invalid states away at the interface before asking every caller to check for them.
- Use the words in `GLOSSARY.md` for names. A concept the glossary doesn't have is a finding to record, not a name to improvise.
- Build what the acceptance criteria ask for. An abstraction for a second use that doesn't exist yet waits for the second use.

## Scope

- Fix what your change broke, and what your slice cannot be correct or safe without. Anything else you notice is written down as deferred and left alone.
- ADRs in `docs/adr/` are binding. A decision that would contradict one is a human's to make.
- A dependency is added only when the spec names it or the install succeeds for the exact package you intended. A failed install is a stop, never a prompt to try a similarly named package.

## Project-specific rules

<!-- Add rules here as retros surface them. Prefer an automated check; write a rule only for a judgement call no check can make. -->
