Slice #{{SLICE}} merged cleanly into the integration branch, and then the gate went red. The slice passed the same gate alone, so the failure comes from how it combines with slices merged before it. You are in the integration worktree.

Read first:

1. `{{GATE_LOG}}`: the failing output.
2. `{{TICKET}}` and `{{STATE}}`: what the slice does, and the decisions behind it.
3. `{{SPEC}}`: the authority on what the combined behaviour should be.

Call the Skill tool with "forge:debugging" and follow it: the gate log already gives you a red, repeatable command, so start from there. Fix the cause at its source, with a regression test at an agreed seam where one fits. Commit the fix with a message naming the interaction that broke.

The gate:

```
{{VERIFY_CMD}}
```

If the cause is that two slices implement contradictory behaviour, change nothing, write what contradicts what to `{{NOTES}}`, and stop. The loop will undo the merge and park the slice for a human.
