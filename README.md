# claude-scaffold

A reusable **skeleton for the `.claude/` directory** — the structure, conventions, and generic
wiring for setting up [Claude Code](https://claude.com/claude-code) in any project. Drop it into a
new repo, fill in the placeholders, and you start with a clean, well-organized agent config instead
of a blank directory.

It ships the *bones* (taxonomy + conventions + a couple of genuinely generic pieces) plus **one
templatized example of each kind** to copy from. It deliberately carries **no** project-specific
domain knowledge.

## Quick start

```bash
# From the project you want to scaffold:
cd ~/dev/projects/new-thing
~/dev/projects/claude-scaffold/install.sh .

# …or pass the target explicitly from anywhere:
~/dev/projects/claude-scaffold/install.sh ~/dev/projects/new-thing
```

`install.sh` copies `.claude/` and `CLAUDE.md` into the target and **never overwrites existing
files** (safe to re-run; it reports what it skipped). It also marks hooks/scripts executable.

Prefer to do it by hand? It's just files:

```bash
cp -r ~/dev/projects/claude-scaffold/.claude  yourproject/
cp    ~/dev/projects/claude-scaffold/CLAUDE.md yourproject/
```

## After installing — make it yours

1. **`CLAUDE.md`** — the map of your config. Fill in the `<PLACEHOLDERS>`, prune unused rows. Keep
   it a *glossary*: no project facts, just pointers to the skills/docs that hold them.
2. **`.claude/settings.json`** — replace the example `permissions.allow` with the tools your project
   actually uses; keep the `deny` list as a safety floor.
3. **Build real skills/agents/commands** from the templates (see below), then delete the leftovers.

## What's in the box

```
.claude/
├── settings.json            # permissions + hook wiring ($CLAUDE_PROJECT_DIR-relative)
├── agents/
│   ├── code-reviewer.md      # ready-to-use generic subagent
│   └── _TEMPLATE.md          # copy → new subagent (with authoring notes)
├── skills/
│   └── _example/SKILL.md     # how to write a skill (the description/triggers contract)
├── commands/
│   ├── review.md             # ready-to-use /review slash command
│   └── _TEMPLATE.md          # copy → new command ($ARGUMENTS, !bash, @file notes)
├── rules/
│   ├── code-style.md         # generic conventions to fill in
│   └── testing.md            # generic verification story to fill in
├── hooks/
│   ├── validate-python.py    # PostToolUse: ruff format + check on edited .py (generic)
│   └── validate-bash.sh      # PreToolUse: blocks rm -rf of root/home (+ your rules)
├── scripts/                  # helper scripts called by hooks/commands (README inside)
└── docs/                     # agent working memory — pulled on demand, never auto-loaded
    ├── README.md             #   the recall/record protocol + "what goes where"
    ├── roadmap.md            #   living backlog
    ├── sessions/             #   dated refined session summaries (+ _template.md)
    └── reference/            #   stable "how we do X" notes
CLAUDE.md                     # the glossary/map (this is what loads every session)
install.sh                    # the drop-in installer
```

## The conventions worth knowing

- **CLAUDE.md is a map, not a manual.** It stays small and points at everything else, so it never
  rots. Deep knowledge lives in skills; "what happened" lives in `docs/sessions/`.
- **Skills auto-surface by `description`.** Write that field for *discovery* — pack it with the
  words and triggers a user would actually type. See `skills/_example/SKILL.md`.
- **Subagents dispatch by `description` too**, and get least-privilege tools. One agent, one job.
- **The `docs/` memory system** lets a fresh session resume with context: refined session summaries
  (not transcripts), a roadmap, and reference notes — all pulled in on demand, never auto-injected.
- **Hooks are wired in `settings.json`** via `$CLAUDE_PROJECT_DIR/.claude/...` so they're portable.

## Conventions for placeholders

- `<PLACEHOLDER>` — fill in.
- `_TEMPLATE.md` / `_example/` — copy to a real name, then delete the original once you've got your own.
- Anything in an HTML comment (`<!-- ... -->`) is authoring guidance; delete it in real files.
