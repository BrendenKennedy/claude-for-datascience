# `.claude/docs` — agent working context

Persistent, **agent-facing** working memory so a new session can resume with the context of the
last one. This is distinct from any repo-root `docs/` (human/project docs). Keep everything here
**refined, not raw**: summaries an agent skims in seconds, never full transcripts or memory dumps.

## Layout
| Path | Holds |
|---|---|
| `sessions/` | dated, refined summaries of each substantive session + current state; cross-referenced |
| `reference/` | stable tool/topic notes that recur but don't warrant a full skill |
| `roadmap.md` | the living backlog: future feature scope + open TODOs |

## How it's used — on demand, never auto-injected

This context is **pulled in only when needed**. There is no start-of-session ritual — reach for it
when a question or task actually calls for it.

**Recall (read) — when the user references earlier work.**
Triggers: "what did we do / decide on X", "in the last few sessions…", "what was the outcome of…",
"remind me", "previously…". Then:
1. `ls sessions/` (dated filenames sort newest-last) and/or `grep sessions/` for the topic.
2. Read the relevant entry (or the latest 1–3) and answer from it.

**Record (write) — after substantive work** (so recall has something to pull from):
1. Add `sessions/YYYY-MM-DD-<slug>.md` from `sessions/_template.md` — refined, with links to related
   sessions and roadmap items.
2. Update `roadmap.md`: check off finished items, add new follow-ups.
3. Add or adjust a `reference/` note if you established a reusable pattern.

## What goes where (so it stays consistent)
- **Deep domain knowledge with triggers** → make it a **skill** (`.claude/skills/`), not a doc here.
- **Reusable "how we do X in this repo"** → `reference/`.
- **What happened / current state** → `sessions/`.
- **What's next** → `roadmap.md`.

If a category outgrows itself (e.g. decision history), split it out — a `decisions/` ADR log is the
obvious next addition.
