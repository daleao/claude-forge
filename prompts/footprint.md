
## Footprint: record the intent first

Anything you create or start on the host machine that is not a file inside this worktree must be written down **before** you create it. The record is a statement of intent, written ahead: if you are cut off one command later, the run still knows what to look for. A record written afterwards, from memory, is the thing this rule exists to prevent.

So the order is always: add the intent to `{{RECORD}}`, then run the command. This covers:

- containers, volumes, networks and images
- processes that keep running: dev servers, watchers, databases, browsers
- files and directories outside this worktree: temp files, caches, downloads (Playwright browsers, toolchains)
- packages and tools installed outside this worktree
- anything else a person would have to remove by hand

Files inside this worktree need no record: the worktree is removed whole.

One block per item, added to the end of the file before the command runs:

```
### <what you are about to create, in a few words>
- Kind: container | volume | network | image | process | file | package | cache | other
- Identifier: <the name, id or path it will have; choose the name yourself where the tool lets you, so it can be found again>
- Command: `<the command you are about to run>`
- Location: worktree | workspace | host
- Shared: no | yes | unknown — <who else uses it: another slice, another project, the user>
- Remove with: `<the exact command that undoes it>`
```

`Location` is `workspace` for anything under the repository's `.forge/` directory, `host` for anything else outside this worktree. `Shared` is `no` only when you are creating it and nothing else can use it; when the command reuses or adds to something that may already exist (a package cache, a pulled image), it is `yes`.

If you do not know what a command will leave, record that: the command, and `Identifier: unknown`. If you later remove something yourself, add `- Outcome: removed` to its block; if the command failed and created nothing, add `- Outcome: not created`. Those lines are optional. The intent is not.

Every Bash command you run is also written to a journal before it runs, and the cleanup pass reads that journal against your intents. A command that created something with no intent ahead of it is treated as an unknown footprint and handed to the human.

Remove only what you started inside this worktree's own scope; anything on the host stays where it is. Earlier records are in `{{REGISTRY}}`.
