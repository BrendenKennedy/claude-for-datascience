# Session: Scaffold self-assessment loop

**Date:** 2026-07-18 · **Focus:** give the scaffold a meta-loop for its own quality — capture dogfooding friction/wins and turn them into scaffold changes

## Summary
Second half of the pre-dogfooding hardening. The scaffold already had a meta-loop for the
*methodology* (PROCESS.md Part V) but none for the *tooling* (`.claude/` config) — so the most
valuable dogfooding signal (a skill that didn't surface, a dropped agent handoff, a hook that fought
you, a missing command) would evaporate into session notes that track the project, not the scaffold.
Built the missing loop: a journal (capture) + a wrapup step (discipline) + `/scaffold-retro` (assess).
Shipped in the scaffold (not dev-only) so friction is captured wherever dogfooding happens and it
doubles as an upstream-feedback channel.

## Changes & artifacts
- `.claude/memory/scaffold-journal.md` — **new** ledger. Kinds: works · friction · coordination ·
  missing · improved. Capture discipline ("log the moment it bites"), a Themes section maintained by
  the retro, an empty log. Ships clean.
- `.claude/commands/scaffold-retro.md` — **new** command. Reads journal + roadmap + CHANGELOG,
  clusters open entries into themes, proposes Fix-now / Roadmap / Leave per theme, user decides, then
  records outcomes + ties resolved friction to the version that fixed it. Proposes, never acts alone.
- `.claude/skills/memory/SKILL.md` — added scaffold-journal to the data-store table + a **step 4
  (scaffold check)** to the Record sequence.
- `.claude/commands/wrapup.md` — mirrored the scaffold-check into the record step (kept in sync with
  the skill).
- `CLAUDE.md` (commands table + memory section), `README.md` (commands + memory rows), `CHANGELOG.md`
  ([Unreleased] Added), `docs/REFERENCE.md` (regenerated) — drift check demands the new command be
  named in CLAUDE.md + README.

## Key decisions
- **Ship it, don't keep dev-only** — friction gets captured wherever dogfooding runs (this repo or a
  fresh install), and it's an upstream-feedback channel. Kept to one skippable wrapup line so
  non-dogfooding consumers aren't taxed.
- **Full loop now (journal + capture + retro)** — you can't retro an empty ledger, but the retro
  completes the "track AND assess" the user asked for; both built together.
- **Two meta-loops, deliberately parallel** — PROCESS.md Part V versions the methodology;
  scaffold-journal + `/scaffold-retro` version the tooling. Same shape, different artifact.
- **Retro proposes, user decides** — same human-in-the-loop discipline as `/gate`; no unilateral
  scaffold edits.

## State
- Works now: all 7 `check-scaffold.sh` checks pass (file count 90→93); REFERENCE regenerated + diffed;
  new command frontmatter valid. The completion contract from the prior session (SessionStart hook +
  DoD) is live on main; this session layered the assessment loop on top.
- **Process phase:** not started (scaffold-dev work on the framework itself, not a gated project) ·
  **gate debt:** none.
- Known gap: both loops are unproven until real dogfooding generates journal entries + a first retro.

## Follow-ups
- First real dogfooding run should exercise: SessionStart briefing → wrapup scaffold check → after a
  few sessions, first `/scaffold-retro` → confirm friction→improved trail actually forms → ../roadmap.md
- Watch that the wrapup scaffold-check doesn't become rote "none" — if it does, the capture-the-moment
  discipline is the real path and the wrapup step is just a backstop → ../roadmap.md

## Related
- Branch: `scaffold-journal` · commit `d96618d`
- Directly builds on [session-start-orientation](2026-07-18-session-start-orientation.md) (the other
  half of the completion contract — orientation in, DoD out)
- Parallels the methodology meta-loop in PROCESS.md Part V
