# CLAUDE.md — index of this repo's `.claude/` config

This file is the **glossary / map** of the Claude configuration here. It holds **no project
knowledge** — it only tells the agent *what lives under `.claude/` and when to reach for each
piece*. For the project itself (what it is, how to run it), point at the primary skill and
`README.md`. Keeping project facts OUT of here is deliberate: it stays small, loads every session,
and never goes stale because the detail lives in the skills/docs it points to.

> Scaffolded from **claude-scaffold**. Fill in the `<PLACEHOLDERS>` and prune rows you don't use.

**How the config loads:**
- **Skills** auto-surface by their `description` — invoke the matching skill *before* acting in its
  domain (it carries the ground-truth detail).
- **Subagents** dispatch by `description` — delegate focused work to the right specialist.
- **Rules** are modular guidance — read the relevant file *before* editing the files it governs.
- **Commands** are slash commands — run them on request.
- **Hooks** run automatically around tool calls (wired in `settings.json`).

## Skills — `.claude/skills/<name>/SKILL.md`
| Skill | Reach for it when… |
|---|---|
| `<skill-name>` | <the domain it owns and when it's the source of truth> |

## Subagents — `.claude/agents/<name>.md`
| Agent | Use for |
|---|---|
| `code-reviewer` | reviewing the current diff for correctness + quality |
| `<agent-name>` | <the focused work to delegate to it> |

## Rules — `.claude/rules/<name>.md` (read before editing)
| File | Read before… |
|---|---|
| `code-style.md` | editing source files (project conventions, idioms) |
| `testing.md` | adding or running tests / verifying a change |

## Commands — `.claude/commands/<name>.md`
| Command | Does |
|---|---|
| `/review` | review the current `git diff` for bugs + cleanups |
| `/<command>` | <what it does> |

## Hooks — `.claude/hooks/` (wired in `settings.json`)
| Hook | Event | Does |
|---|---|---|
| `validate-bash.sh` | PreToolUse · Bash | blocks recursive force-deletes of root/home (+ your project rules) |
| `validate-python.py` | PostToolUse · Edit/Write | runs `ruff format` + `ruff check --fix` on edited `.py` files |

## Working context — `.claude/docs/`
Persistent agent memory across sessions (refined summaries, **not** raw dumps). **Pulled in on
demand — never auto-loaded.** See `.claude/docs/README.md`.
- **Recall:** when the user references earlier work, search `.claude/docs/sessions/` (files are
  `YYYY-MM-DD-<slug>.md`, newest-last), read the relevant entry, and answer from it.
- **Record:** after substantive work, add a refined `sessions/YYYY-MM-DD-<slug>.md` (from
  `_template.md`) and update `roadmap.md`.

| Path | Role |
|---|---|
| `.claude/docs/sessions/` | dated refined summaries of past sessions; start from `_template.md` |
| `.claude/docs/reference/` | stable tool/topic notes that recur but aren't full skills |
| `.claude/docs/roadmap.md` | living backlog / future scope / TODOs |

## Other config
| Path | Role |
|---|---|
| `.claude/settings.json` | permissions + hook wiring (personal overrides → `settings.local.json`, gitignored) |
| `.mcp.json` | MCP server wiring, if/when you add MCP servers (lives at repo root) |
