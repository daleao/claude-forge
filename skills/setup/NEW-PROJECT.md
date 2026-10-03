# New project

For a folder with no project in it yet. Reached from `/forge:spec` (at publish time, with an approved draft) or from `/forge:setup`.

This prepares a place for the work to happen: a repository and the Forge files. It writes no application code, installs no dependencies, and **does not define the gate**. The gate depends on the stack, and the stack is decided in the spec; so the gate is written by the **foundation slice**, the first slice of `forge run`, as part of building the scaffold.

Do each step yourself and skip any that is already done. Keep the same **done for you** / **needs you** list as `/forge:setup`.

## 1. Make it a repository

```bash
git init -b main
```

## 2. Install the Forge project files

```bash
bash <plugin root>/install.sh .
```

(`<plugin root>` is two levels above this file.)

Leave `FORGE_VERIFY_CMD` and `FORGE_SETUP_CMD` empty in `.forge/config.sh`. `forge run` accepts an empty gate at the start only when the spec has a slice marked `## Foundation`, and that slice cannot finish until it has written a gate that passes.

## 3. Allow the foundation slice its tools

One setting does belong here, because it is a permission and permissions are granted by a human before the run, never by the agent during it. If an approved spec exists, read its "Project foundation" section and add to `FORGE_ALLOWED_TOOLS` in `.forge/config.sh` a `Bash(<command>:*)` entry for each command the scaffold needs: the package manager, any scaffolding command, the test runner, the typechecker, the linter (for a Node project: `Bash(npm:*)`, `Bash(npx:*)`, `Bash(node:*)`). Show the user the entries you added.

If there is no approved spec yet, skip this step and put it under **needs you**: it is done when `/forge:spec` brings you back here.

## 4. First commit

Commit what exists: `.forge/config.sh`, `.forge/constitution.md`, `.forge/.gitignore`, and any `GLOSSARY.md` and `docs/adr/` the interview produced. Add a `CLAUDE.md` with the two pointer lines from `/forge:setup` step 6.

## 5. Create the GitHub repository

This publishes the folder, so agree two things with the user first: the repository **name** (suggest the folder's name), and whether it is **private** (suggest private). Then give them this to run in their own terminal; creating a repository is outside what `forge` does for a session, on purpose:

```bash
gh repo create <name> --private --source . --remote origin --push
```

## 6. GitHub access

Follow step 5 of `/forge:setup`: `forge doctor`, and the sandbox settings if this session is sandboxed.

Return to the skill that sent you here. From `/forge:spec`, the next action is publishing the spec issue. From `/forge:setup`, continue at its step 7, and in the final report list "the gate" under **done for you** as "defined by the foundation slice during `forge run`".
