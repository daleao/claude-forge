---
name: run
description: Step 4 of the Forge pipeline. Preflight a sliced spec and launch the unattended build loop.
argument-hint: "The spec issue number"
disable-model-invocation: true
---

Launch the unattended build for a spec that `/forge:slice` has already sliced. The work itself is done by the `forge` script, in fresh headless contexts outside this session; your job is the preflight and the launch.

## 1. Preflight

Check each of these and report what you found. A failed check is a stop: fix it with the user before launching.

- [ ] `.forge/config.sh` exists and `FORGE_VERIFY_CMD` is set. Run that command on the base branch now; it must exit 0. A red baseline makes every slice fail its gate. The one exception is a new project: the gate may be empty or failing now if, and only if, one slice carries a `## Foundation` heading. That slice runs first and alone, writes the gate into `.forge/config.sh`, and makes it pass.
- [ ] `forge doctor` reports no failure.
- [ ] The spec issue has a `## Slices` list, and every slice has `## Blocked by` and `## Touches` (`forge issue view <n>`).
- [ ] The blocking edges form no cycle, and every blocker is either in the Slices list or a closed issue.
- [ ] Agents can run what they need. The commands the gate and setup commands start with are allowed automatically; anything else an implementer needs (a scaffolding command in a new project, a single-test runner) must be in `FORGE_ALLOWED_TOOLS`. Without `--yolo`, a command outside the allowed set is denied and the iteration loses its feedback loop.

## 2. Show the plan

Print the waves the blocking edges allow (what starts immediately, what each later slice waits on), the parallel limit, and the models from the config. Ask the user to confirm, and whether they want `--yolo`: it runs agents with all permission checks off, and belongs in a container or VM.

## 3. Launch

Start the script in the background so it outlives this turn, logging to a file. Use `--log`, not a shell redirect, and put nothing else in the call: in a sandboxed session a redirect, a pipe or a `cd` keeps the whole call inside the sandbox, where the run can reach neither GitHub nor its agents.

```bash
forge run <spec> --log .forge/runs/<spec>.log
```

Add `--yolo` only if the user asked for it. Tell the user how to watch it:

- `forge status <spec>`: each slice's status, and what blocks the parked ones
- `tail -f .forge/runs/<spec>.log`: the scheduler's log
- `.forge/runs/<spec>/slices/<n>/state.md`: one slice's memory, live

The run ends on its own with a QA report and, unless `--local`, a PR. The next step is `/forge:review <spec>`.

## If the run pauses

The script exits with status 75 and the line `paused: <reason>` when it stops itself: a usage limit was reached, the usage threshold was crossed, or an agent call failed outright. A pause is not a failure of the work. Every slice keeps its state, nothing is parked, and an audit that could not finish is reported as incomplete, never as clean. `forge status <spec>` shows the reason. Run `forge run <spec>` again once the cause has cleared (for a usage limit, after it resets).

## If a slice is parked

A blocked slice stops only itself and the slices behind it. To restart one: read its `state.md` and `blocked-reason`, settle the question with the user, write the answer into the state file's **Decisions** and a concrete **Next action**, then `forge unblock <spec> <slice>` and `forge run <spec>` again. The run resumes from the ledger; merged slices are not redone.
