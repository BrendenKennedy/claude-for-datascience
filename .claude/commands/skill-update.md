---
description: >
  Sync a tool skill to the version the project actually runs — compare its **Pinned:** line
  against the locked dependency, research what changed between those versions, update the skill's
  facts, and bump the pin. Run after deliberately upgrading a tool, never on a schedule.
argument-hint: [skill-name | --check]
---

Keep tool skills true for the versions this project runs. Every tool skill carries a
`**Pinned:**` line under its H1 — the version its facts were last verified against. The locked
dependency (`uv.lock`) is the source of truth; the skill follows it. **This command never
upgrades the dep itself** — that's the user's `uv add` (see `env-uv`); a pin bump here without a
lockfile change behind it is a lie.

## `--check` (or no argument): drift report only

For each tool skill that is `"on"` in `settings.json` `skillOverrides`:
1. Read its `**Pinned:**` line.
2. Read the installed version — `uv run python -c "import <pkg>; print(<pkg>.__version__)"`, or
   parse `uv.lock`, or the tool's CLI `--version` (uv itself).
3. Print a table: skill · pinned · installed · verdict (in sync / DRIFT / unpinned / not
   installed). Stop — no edits in check mode.

## `<skill-name>`: research + update that one skill

1. **Delta.** Pinned version → installed version (unpinned skills: target = installed). Not
   installed → stop and say so; there is nothing to verify against.
2. **Research the gap.** WebFetch the tool's official changelog/release notes across the delta
   (WebSearch to locate them). Hunting only for what invalidates or improves the skill's
   documented facts: breaking changes, renamed/removed APIs, deprecations, changed defaults, new
   canonical patterns. Ignore features the skill doesn't document. When the delta spans many
   releases, delegate the reading to a general-purpose subagent and take back a summary — raw
   release notes don't belong in the main context.
3. **Verify empirically — don't trust the changelog either.** Run the skill's load-bearing
   commands against the installed version (imports, the key API calls on toy inputs, CLI
   `--help`). Cheap, and it catches both changelog omissions and this skill's own drift. The
   `testing` skill's ethos applies: never claim a command works that you didn't run.
4. **Edit the skill.** Update only facts that changed; keep the description within the
   authoring-extensions budget rules; bump the banner to
   `**Pinned:** <pkg>==<installed> · verified <today>`.
5. **Record.** Commit (per the `memory` skill's branch conventions) with a message stating
   old pin → new pin and the substantive changes ("mlflow 2.19→3.1: file store removed, aliases
   replace stages"). **Git history is the archive of older skill versions** — a project on an
   older tool version reads the skill from the commit whose pin matches (`git log --oneline --
   .claude/skills/<name>/SKILL.md`); do not keep parallel old copies in the tree. A judgment
   call (e.g. deliberately staying on a deprecated API) also gets a decision-log line
   (`governance`).

## Report

The drift table (check mode), or: pin old → new, what changed in the skill (file+section), the
verification commands actually run with their output, and anything deferred.
