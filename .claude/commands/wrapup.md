---
description: >
  Wrap up the session — run the memory skill's close-out: record the session note, update the
  roadmap, and (if asked) branch/commit/land.
---

Wrap up this session. **Invoke the `memory` skill** and follow its process verbatim — don't reconstruct
the structure from context (that's how sub-steps get dropped). Run its close-out sequence:

1. **Record** — write `.claude/memory/sessions/YYYY-MM-DD-<slug>.md` from the memory skill's template
   (keep every section: Summary · Changes & artifacts · Key decisions · State · Follow-ups · Related),
   refined to ~one screen; update `.claude/memory/roadmap.md` (finished items → Done (recent), add
   follow-ups); add or adjust a `reference/` note if a reusable pattern emerged. In the note's State
   section, record the **current phase + any open gate debt** (from
   `.claude/memory/process/phase-state.md`) so the next session starts oriented.
2. **Branch + commit** — only if the user wants to commit. Branch first if on `main`; end the commit
   message with the project's required trailer(s), if any; then **record the branch name + commit hash**
   in the session note + roadmap entry (the hash goes in a small follow-up commit, per the memory skill).
3. **Land** — merge to `main` (or push + open a PR, per this repo's convention) only when the user
   explicitly asks.

Report each step's outcome and call out anything skipped or deferred.
