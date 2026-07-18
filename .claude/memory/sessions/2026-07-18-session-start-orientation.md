# Session: Session-start orientation hook + definition-of-done convention

**Date:** 2026-07-18 · **Focus:** close the completion-contract gap before dogfooding — automatic session-start orientation + a per-response "finish before handing back" standard

## Summary
User asked whether anything was missing to run DS projects almost entirely through Claude, floating
an orchestrator/validator agent. Rejected the agent (the existing `architecture-skills-vs-agents`
note already kills it; a validator subagent is a worse fit — completeness-checking needs the full
conversation and the user in the loop). Reframed the ask as a **completion contract the main session
runs against itself**, split by determinism: judgment → CLAUDE.md convention, mechanical → hook,
never an agent. Built the automatic session-start bookend (mirror of `/wrapup`) and the per-response
definition-of-done.

## Changes & artifacts
- `.claude/hooks/session-orient.py` — **new** `SessionStart` hook. Injects a compact briefing
  (current phase · open gate debt · last session focus/state/follow-ups · roadmap now+next) + the
  standing kickoff questions. No-ops silently when phase is "not started" (ad-hoc/pre-`/intake`).
- `.claude/settings.json` — wired the hook under `SessionStart`, matcher `startup|clear` (a mid-work
  `resume`/`compact` still has context, so re-injecting there would be noise), with a rationale comment.
- `CLAUDE.md` — added the **"Finish before handing back"** always-on convention (the DoD: ask actually
  satisfied, runtime code exercised, decisions recorded as you go, proactively offer `/wrapup`); added
  the hook to the hooks table.
- `CHANGELOG.md` — `[Unreleased] > Added`: the hook + the DoD convention.
- `docs/REFERENCE.md` — regenerated (picked up the new hook row only).
- `.claude/memory/roadmap.md` — marked "Stop-hook gate-debt warning" superseded.

## Key decisions
- **No orchestrator/validator agent** — main session is already the orchestrator; an agent adds a lossy
  hop and can't see the thread or ask the user. Consistent with the standing architecture note.
- **Completion contract split by determinism** — judgment (DoD) → CLAUDE.md; mechanical (orientation) → hook.
- **Orientation belongs at `SessionStart`, not `Stop`** — `Stop` fires per-*turn*, so a "did you record /
  gate debt" nag there would spam every reply. This supersedes the roadmap's "Stop-hook gate-debt warning".
- **Fire on `startup|clear` only, no-op pre-`/intake`** — keeps ad-hoc use ceremony-free (PROCESS.md's
  "ad-hoc asks don't gate").

## State
- Works now: hook verified both paths (silent no-op on current "not started" state; full briefing against a
  live-phase fixture). `check-scaffold.sh` passes all 6 checks. `settings.json` valid JSON.
- **Process phase:** not started (this is scaffold-dev work on the framework itself, not a project run
  through the gates) · **gate debt:** none.
- Known gap: the hook only takes effect on the **next fresh session**; it stays silent until `/intake`
  sets a live phase. Not yet committed/pushed at time of writing (branch below).

## Follow-ups
- Dogfood and watch whether the orientation briefing is the right length / the DoD convention actually
  fires the wrapup offer → ../roadmap.md
- `/upgrade` path: installed projects get the new hook via the three-way file plan (new file = ADD) → ../roadmap.md

## Related
- Branch: `session-start-orientation`
- Builds on: [architecture-skills-vs-agents](../reference/architecture-skills-vs-agents.md) (why no agent),
  [process-and-efficiency](2026-07-18-process-and-efficiency.md) (the operating loop this bookends)
