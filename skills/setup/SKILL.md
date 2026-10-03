---
name: setup
description: Configure a repo for the Forge workflow (config, constitution, GitHub access). Run once per repo.
disable-model-invocation: true
---

Prepare this repo for the Forge pipeline. Do the work yourself: detect, fill in, create. The user should only have to confirm what you found and decide the few things that are theirs to decide. Every step is idempotent: re-running setup changes only what is missing.

Keep a running list as you go, in two columns: **done for you** and **needs you**. You present it at the end (step 8).

## 1. Check the tools

Run each and note the result:

- `gh --version` (the GitHub CLI; its login is checked in step 5)
- `jq --version`
- `bash --version` (5.1 or newer; on macOS install a current bash)

A missing tool goes under **needs you**, with the exact install or login command for this machine. Offer to run it. Continue with the steps that don't need the missing tool.

## 2. New project or existing project?

Look at the folder. **If it has no project in it yet** (no source code, or not a git repository), this is a new project: read [NEW-PROJECT.md](NEW-PROJECT.md) and follow it instead of steps 3 to 6, then continue at step 7.

An existing project needs a GitHub remote (`git remote get-url origin`). If there is none, agree the repository's name and whether it is private, then give the user this to run in their own terminal: `gh repo create <name> --private --source . --remote origin --push`. Creating a repository is outside what `forge` does for a session, on purpose.

## 3. Install the project files

Run the installer from the plugin root (this skill lives at `<plugin root>/skills/setup/`):

```bash
bash <plugin root>/install.sh .
```

It creates `.forge/config.sh`, `.forge/constitution.md` and `.forge/.gitignore` where they don't exist, and links the `forge` and `forge-usage-statusline` commands into `~/.local/bin`. If it reports that the directory is not on the PATH, put that under **needs you** with the line to add to the user's shell profile, and offer to add it.

## 4. Fill in the two project settings

`.forge/config.sh` has two settings that depend on the project. Everything else in it already has a working default; leave those alone unless the user asks.

Find the project's real commands; don't guess them. Read the build-tool manifest (`package.json` scripts, `Makefile`, `pyproject.toml`, `Cargo.toml`, `justfile`) and the CI workflow.

- **`FORGE_VERIFY_CMD`**, the gate: one command line that runs the tests, the typecheck and the linter and exits 0 only when all pass.
- **`FORGE_SETUP_CMD`**: what a fresh checkout needs before the gate can run (install dependencies, generate code). Git worktrees don't share untracked files such as `node_modules`.

Write both into the file, then **run the gate** on the current branch.

- It passes: record both under **done for you**, showing the exact commands you chose.
- It fails, or the project has no tests, typecheck or linter to build a gate from: this is the one thing setup cannot settle alone. Put it under **needs you**, say what is failing or missing, and offer the fix (repair the failing check, or add a minimal test runner with one real test). The loop refuses to run on a failing gate.

You don't need to touch `FORGE_ALLOWED_TOOLS` for these: the script automatically allows the commands the gate and setup commands start with. Add an entry only for another command an implementer will clearly need, such as a separate single-test runner.

## 5. GitHub access

A session never calls `gh` itself. It reaches GitHub through a few fixed `forge` commands (`forge issue view|create|edit`, `forge pr view|push`), which work on this repo's `origin` and nothing else. Check that they work:

```bash
forge doctor
```

Run it alone: no pipe, no redirect, no `cd` in the same call. Record a clean result under **done for you**.

**If the session uses the Bash sandbox**, `forge doctor` reports the GitHub login as failing until those commands are allowed to run outside the sandbox. The settings for that are in `<plugin root>/templates/sandbox-settings.json`: they take only the GitHub commands and the launch of a run out of the sandbox, ask before each one that writes, and stop sandboxed commands reading the `gh` token. Read the user's `~/.claude/settings.json`, show them what would be merged in, and merge it on a yes. This is their personal settings file; if they decline, put it under **needs you**. If `forge doctor` still fails afterwards, the settings take effect in a new session.

A login that fails outside a sandbox goes under **needs you** with `gh auth login`.

The `forge:spec` and `forge:slice` labels need no step: `forge issue create` adds each the first time it is used.

## 6. Point agents at it

Add these lines to `CLAUDE.md` (create it if needed), and nothing more:

```md
- Engineering rules: `.forge/constitution.md`
- Domain language: `GLOSSARY.md`. Decisions: `docs/adr/`
```

## 7. Usage threshold

The config already pauses a run when subscription usage reaches 90% (`FORGE_USAGE_STOP_PERCENT`). That only takes effect once Claude Code's status line records the usage, which needs one entry in the user's own `~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "forge-usage-statusline" }
```

Read that file first.

- No `statusLine` entry: offer to add this one.
- An existing `statusLine`: leave it. Offer to add the one-line `--record-only` call (shown in the header of `scripts/usage-statusline.sh`) to the user's own status line script.

This is the user's personal settings file, so change it only on a yes. If they decline, put it under **needs you** as optional. Either way, tell them the limits: readings exist only on Pro and Max plans, they update only while an interactive session is active, and a run that reaches the limit pauses cleanly and resumes regardless.

## 8. Report, then offer to finish

Present the two lists. For every **needs you** item give: what it is, the exact file and line or the exact command, and an offer to do it now. A typical clean result looks like this:

```
Done for you
  ✔ Tools: gh, jq, bash 5.2
  ✔ .forge/config.sh        gate:  npm test && npm run typecheck && npm run lint   (passes)
                            setup: npm ci
  ✔ .forge/constitution.md  general rules installed
  ✔ GitHub: logged in, origin acme/shop   (forge doctor)
  ✔ CLAUDE.md pointers
  ✔ forge and forge-usage-statusline on your PATH

Needs you
  1. Project rules (optional)   .forge/constitution.md, under "Project-specific rules"
                                Tell me any judgement-call rules for this codebase and I'll add them.
  2. Usage status line (optional)   ~/.claude/settings.json, "statusLine"
                                Say yes and I'll add it.
  3. Commit the setup           .forge/config.sh, .forge/constitution.md, .forge/.gitignore, CLAUDE.md
                                Say yes and I'll commit them.
```

Act on each item the user accepts. When the list is empty or only optional items remain, tell the user the pipeline starts at `/forge:grill`, and that `/forge:help` shows the whole flow.
