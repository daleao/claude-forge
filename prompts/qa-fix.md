An independent QA audit of this branch produced the findings in `{{FINDINGS}}`. You fix them. You are in the integration worktree; this is fix round {{ROUND}}.

Read first:

1. `{{CONSTITUTION}}`: the engineering rules for this repo.
2. `{{FINDINGS}}`: every open finding. `[BLOCKER]` and `[IMPORTANT]` are yours; `[MINOR]` ones are left for the human.
3. `{{SPEC}}`: the authority. `{{SLICES}}` holds the slice tickets.

Treat each finding as a claim to verify, not an order. For each one, in the order listed:

1. **Check it against the code.** Read what the finding points at. Reviewers work from a diff and are sometimes wrong.
2. **If it is right**, fix it test-first: call the Skill tool with "forge:tdd". A finding about a missing or hollow test is fixed by a test that goes red for the right reason before it goes green. Commit each fix separately, naming the finding.
3. **If it is wrong, or fixing it would contradict the spec**, change nothing and record why.

Then run the gate until it exits 0:

```
{{VERIFY_CMD}}
```

Finally write `{{NOTES}}`, one line per finding, in the findings' order:

- `FIXED <finding, shortened> — <commit> — <the test that covers it>`
- `DECLINED <finding, shortened> — Ruling: <why the code stands> — <what it costs if wrong>`

Fix only what the findings name. An improvement nobody asked for widens the diff the next reviewer has to recheck.
