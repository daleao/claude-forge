---
name: cleanup
description: Walk the human through what a Forge run left on the machine, one manual cleanup step at a time.
argument-hint: "The spec issue number"
disable-model-invocation: true
---

A run leaves things on the machine: containers, volumes, caches, downloaded browsers, temp files. Every agent recorded what it left in the run's cleanup registry, and a cleanup pass at the end of the run removed what was safe. What it judged unsafe is waiting for a person. Your job is to take the user through those steps one at a time. The decisions are theirs; you supply what they need to make each one.

## 1. Read the state

- `.forge/runs/<spec>/cleanup-registry.md`: everything recorded, and the verdicts of each cleanup pass at the end.
- `.forge/runs/<spec>/cleanup-manual.md`: the steps left for a person.

If the registry has no `## Cleanup pass` section, or its last entry says `INCOMPLETE`, no pass has checked the run. Tell the user, and offer to run one: `forge cleanup <spec>`. Do not walk through steps from a registry no pass has checked.

If a `forge run` for this spec is still going or paused and about to be resumed, say so first: what it started is what the resumed run will use.

## 2. Report

One short summary before any step:

- what the pass removed on its own (a count, and the items in a line each)
- what it kept on purpose (worktrees, branches, the run directory) and when those go
- how many manual steps are open, and what kinds: running things, data, disk space

## 3. One step at a time

Take the open steps in the file's order. For each one:

1. **Check it now.** Run the step's `Check it first` command. The file was written when the run ended; things change. If the item is gone, mark the step and move on.
2. **Present it**: what it is, where it came from, why the pass left it, the exact command, and what the user loses by running it. Add what the check just showed (size, age, whether anything is attached to it).
3. **Ask**: remove it, keep it, or skip for now. Give your recommendation and the reason. For an item shared with other projects (a package cache, a browser download, an image), the recommendation is usually to keep it.
4. **Act on the answer.**
   - Remove: the user runs the command themselves (`! <command>` in this session), or tells you to run it. Run exactly the command shown, for this one step. An approval covers one step; never carry it to the next, and never join steps into one command.
   - Then run the check again and say what it shows.
5. **Record it** in `cleanup-manual.md`: change the step's `Status: open` to `done`, `kept` or `skipped`, with the date and, for `kept`, the user's reason.

If a command fails, show the output and stop on that step. Do not reach for a stronger command (`-f`, `sudo`, a wider path) unless the user asks for it by name.

A step whose command deletes outside the repository, removes data, or uninstalls something is read back in full before it runs: the exact path or name, and what the user said yes to.

## 4. Close

When every step is `done`, `kept` or `skipped`, summarise the three lists. Then the last things forge itself left, which stay until the PR is merged or the run is abandoned:

```bash
forge clean <spec>          # the worktrees
```

The branches `forge/<spec>/*` and the run directory `.forge/runs/<spec>/` go by hand after that. The registry and this record live in the run directory, so it goes last.
