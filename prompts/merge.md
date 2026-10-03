A merge of slice #{{SLICE}} into the integration branch stopped on conflicts. You are in the integration worktree, mid-merge.

Read first:

1. `{{TICKET}}`: what the slice being merged was built to do.
2. `{{STATE}}`: its decisions and rulings.
3. `{{SPEC}}`: the parent spec, the authority when the two sides disagree.

Then resolve:

1. `git status` lists the conflicted files. For each one, read both sides and `git log --oneline -5 -- <file>` on each parent to learn what each side was doing.
2. Keep both behaviours. A conflict here means two slices changed the same place for different reasons; the resolution almost always carries both changes, never one side wholesale.
3. Run the gate, and fix what the resolution broke until it exits 0:

```
{{VERIFY_CMD}}
```

4. `git add` the resolved files and `git commit --no-edit` to conclude the merge.

If the two sides cannot both be honoured (they implement contradictory behaviour), leave the merge unresolved, write what contradicts what to `{{NOTES}}`, and stop. The loop will abort the merge and park the slice for a human.
