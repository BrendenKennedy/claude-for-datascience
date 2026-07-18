---
name: memory
description: >
  Cross-session working memory + the branch-per-session git workflow — the read/write process for
  `.claude/memory/` (`sessions/`, `roadmap.md`, `reference/`). RECALL: when earlier work is
  referenced, grep/read `sessions/` newest-last and answer from it. RECORD: after substantive work,
  add `sessions/YYYY-MM-DD-<slug>.md` from the template + update the roadmap. REFERENCE: promote
  reusable patterns to `reference/`. BRANCH: don't commit straight to main — branch per
  session/wave, commit only when asked, land, note branch+hash in the session record. Load when
  starting or wrapping a unit of work, or when past sessions come up. Triggers: record the session,
  wrap up, close out, session note, roadmap, what did we do, what did we decide, last session,
  recall, remind me, start a branch, feature branch, land this, merge to main, commit this.
---

# Memory — journaling past work + branch hygiene

> On-demand: load when you **start** a unit of work (branch it), **wrap one up** (record it), or when
> the user **references earlier sessions** (recall it). `.claude/memory/` holds the stored notes (the
> DATA); this skill is the PROCESS that reads and writes them — pulled in on demand, never auto-loaded.
> (This is the in-repo, project-scoped memory — not the personal auto-memory at `~/.claude/projects/**/`.)

## The data store (where notes live)
| Path | Holds |
|---|---|
| `.claude/memory/sessions/` | dated refined summaries of each substantive session (`YYYY-MM-DD-<slug>.md`, newest-last) |
| `.claude/memory/roadmap.md` | living backlog: next · in-progress · done-recent |
| `.claude/memory/reference/` | stable "how we do X" notes that recur but don't warrant a full skill |

(`.claude/memory/policy/` also lives under memory — authored governance canon — but it's owned by the `governance` skill, not this one.)

## Recall — when the user references earlier work
Triggers: "what did we do / decide on X", "in the last few sessions", "remind me", "previously".
1. `ls .claude/memory/sessions/` (dated names sort newest-last) and/or grep it for the topic.
2. Read the relevant entry (or the latest 1–3) and answer from it. Don't re-derive what a note records.

## Record — after substantive work
1. Add `.claude/memory/sessions/YYYY-MM-DD-<slug>.md` from the template below — a *refined* summary, not
   a transcript (~one screen: outcomes + current state, not every step). Cross-link related sessions.
2. Update `roadmap.md`: check off finished items, move them to **Done (recent)**, add follow-ups.
3. If you established a reusable "how we do X", add/adjust a `reference/` note (or promote it to a skill).

Naming: ISO date + kebab slug (`2026-01-15-project-bootstrap.md`).

### Session template (copy into the new file — keep these sections)
```
# Session: <title>

**Date:** YYYY-MM-DD · **Focus:** <one-line focus>

## Summary
<2–4 sentences: the goal of the session and what was actually accomplished.>

## Changes & artifacts
- <path> — <what changed / why>

## Key decisions
- <decision> — <one-line rationale>

## State
- <what works now> · <what's in progress> · <known gaps>

## Follow-ups
- <open thread> → ../roadmap.md

## Related
- <link to prior/related session, or "first session">
```

## Branch management — the git workflow around a session
- **Branch per unit of work, off `main`.** Don't commit straight to the trunk — cut a branch named for
  the work (e.g. `<topic>-<slug>`). Matches the harness rule: *on the default branch, branch first.*
  Trivial docs-only touch-ups are the only reasonable exception.
- **Commit only when the user asks.** End every commit message with the project's required trailer(s),
  if any (`<PLACEHOLDER — e.g. a Co-Authored-By line>`).
- **Land it.** "Land" = merge the branch into `main` (locally, or push + open a PR — `<PLACEHOLDER: this
  repo's landing convention>`). Record the **branch name** in the session note + roadmap up front (it's
  known before you commit); add the **commit hash** in a small follow-up commit or read it from git later.

## Close-out (the wrap-up sequence)
**Land the branch → record the session note → update the roadmap.** One coherent unit of work = one
session note. Keep the roadmap status and the session prose from drifting. The **`/wrapup`** command
drives this close-out end-to-end (record → optional commit → land) as a checklist — prefer it over
reconstructing the steps from memory.

## Gotcha
The `.claude/memory/` notes are the DATA; this skill is the *only* source of the RECALL / RECORD /
BRANCH rules — consolidated here (not in CLAUDE.md) so they surface exactly when you're starting,
branching, or wrapping up work, and don't tax always-on context every session.
