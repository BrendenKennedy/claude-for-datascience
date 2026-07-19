# Scaffold journal — how the `.claude/` config itself is holding up

The longitudinal record of how the **scaffold** (skills · agents · commands · hooks · the process
docs) performs *in use* — the tooling's own quality signal, kept separate from the project work
(that lives in `sessions/`). This is the data behind the scaffold's meta-loop: the mirror of
`PROCESS.md` Part V, which versions the *methodology* — this versions the *tooling*.

> **Why this exists:** the most valuable dogfooding signal (a skill that didn't surface when it
> should have, an agent handoff that dropped context, a hook that fought you, a command you wished
> existed) is exactly the signal that evaporates — session notes track the project, not the scaffold.
> This file catches it so it becomes a decision instead of a vague memory.

## Capture discipline
- **Log the moment it bites.** When the scaffold helps or hurts mid-session, add a row *now* — same
  rule as the risk register. Reconstructing friction at wrapup loses the specifics.
- **Backstop at wrapup.** The `/wrapup` close-out asks for a scaffold check; "none this session" is a
  valid, common answer. Don't manufacture entries — an empty session is fine.
- **One home.** Scaffold-quality signal lives *here*. Forward feature ideas still go to
  `roadmap.md`; this file is *observed* friction/wins, which `/scaffold-retro` later promotes into
  roadmap/CHANGELOG items.

## Kinds
| Kind | Means |
|---|---|
| `works` | a component clearly helped — a pattern worth keeping or extending |
| `friction` | something was clunky, slow, noisy, or fought the work |
| `coordination` | an inter-component handoff (skill↔skill, agent↔main-session, command↔skill, hook×hook) that worked or didn't — the subtle failure mode |
| `missing` | a wished-for skill / command / hook / doc that doesn't exist |
| `improved` | a shipped change that resolved a prior entry (ties friction → the version that fixed it) |

## Themes / recurring
_Maintained by `/scaffold-retro`: clusters of open entries that keep recurring = what to build or
fix next._

**Harvested from the `dota2-prediction-engine` dogfood (scaffold v0.7.0, 18 journal entries + the
final report's Part II) — 2026-07-19.** The first full end-to-end run of the scaffold on a real
project (P1 intake → P5 close on an honest negative result). Clusters, ranked by the dogfood, and
where each landed in **v0.9.0** (this patch):

1. **No predictive-signal screen before modeling spend** *(headline / highest impact)* — EDA
   audited data quality/quantity but never screened features vs the target, so the near-random
   ceiling was confirmed *late* (after the full P4/P5 spend) when a cheap train-only screen at P3
   would have caught it. → **fixed v0.9.0:** `eda` predictive-signal-screen section + P2 key
   activity + **P3 exit-gate go/no-go** (PROCESS.md 0.3.0).
2. **`.claude/memory/` ↔ `docs/` double-entry** *(3× — highest frequency)* — process state
   hand-mirrored into two homes; drift one forgotten edit away. → **partially addressed v0.9.0:**
   `/intake` VC-scope question establishes one canonical home + "regenerate, never hand-mirror" as
   guidance. *(Open: no tool yet auto-regenerates `docs/` snapshots — roadmap item.)*
3. **`/gate` ↔ `roadmap.md` drift** *(2×)* — gate advanced the phase ledger but left the roadmap
   Now block stale. → **fixed v0.9.0:** `/gate` PASS now cascades to the roadmap.
4. **`/intake` inferred the environment instead of asking** — inferred CPU/SQLite from the plan
   when the real box was DGX Spark ARM+GPU + Postgres. → **fixed v0.9.0:** baseline env-confirm is
   now a mandatory, un-skippable question, never inferred from the plan doc.
5. **Environment-conflict gaps** — `guard-pyproject` false-blocked legit `[tool.ruff]`/`[tool.pytest]`
   edits; `env-uv` had no isolated-GPU-env pattern (RAPIDS/numba vs numpy); ruff E501 in prose
   un-autofixable; `.gitignore` hid `.claude`/`PROCESS.md`. → **fixed v0.9.0:** guard anchored on
   TOML table headers; `env-uv` isolated-GPU-env + line-length-100 convention; `/intake` VC-scope
   handles `.gitignore`.
6. **`skillOverrides` not re-read at Skill-invocation** *(coordination — harness limitation)* — a
   mid-session flip surfaced the description but the invocation gate stayed pre-edit. → **documented
   v0.9.0** in `/intake` (not scaffold-fixable; needs a session boundary).

**Wins to keep (from the same dogfood):** cache-first ingest client compounding across M1→M3
(`data-acquisition`); "prove the spine on synthetic, flip to real" (`tabular` — documented as the
default in v0.9.0); baselines-first as the true signal guardrail; async `software-architect` +
parallel context-gathering; `local-stack` Postgres+MinIO up first try.

## Log
_Newest-last. Keep cells terse; `Status` is `open` or `resolved (vX.Y / commit)`._

| Date | Kind | Component(s) | Observation | Proposed action | Status |
|------|------|--------------|-------------|-----------------|--------|
| 2026-07-18 | coordination | `/wrapup` × `memory` skill | The wrapup command restates the memory skill's step list, so adding the scaffold-check step meant editing *both* — they can silently drift. It's a deliberate tension (the skill says "don't reconstruct from context", hence the restatement). | Watch for real drift; if it bites, make `/wrapup` reference the skill's numbered steps instead of copying them. | open |
| 2026-07-18 | works | `check-scaffold.sh` (drift + reference checks) | While adding `/scaffold-retro`, the drift check forced it into CLAUDE.md + README and the reference check caught the stale REFERENCE.md — doc/territory consistency held automatically during the loop's own construction. | Keep; pattern worth relying on when adding any command/skill/agent. | open |
| 2026-07-18 | works | `check-scaffold.sh` (install file-count check) | Caught an over-broad exclusion glob (`*/memory/*` matched `templates/memory/` too, so the new templates silently didn't ship) as an off-by-2 immediately — bug never left the branch. Second instance of the same theme: the count-based install check pays off. | Keep. Theme forming: check-scaffold is the scaffold's load-bearing guardrail. | open |
| 2026-07-19 | improved | `eda` · `PROCESS.md` P2/P3 | Harvested dogfood theme #1 (signal screen). Added the predictive-signal screen to `eda` + a P3 exit-gate go/no-go + P2 probe. | Shipped. | resolved (v0.9.0) |
| 2026-07-19 | improved | `/gate` · `roadmap.md` | Harvested dogfood theme #3. `/gate` PASS now cascades the passed item into the roadmap Now→Done. | Shipped. | resolved (v0.9.0) |
| 2026-07-19 | improved | `/intake` | Harvested dogfood themes #4/#2/#5/#6. Mandatory env baseline-confirm; VC-scope question (`.gitignore` + canonical-home + git-add short-circuit); skillOverrides session-boundary note. | Shipped. | resolved (v0.9.0) |
| 2026-07-19 | improved | `guard-pyproject.py` | Harvested dogfood theme #5. DEP_PATTERN anchored on TOML table headers (9-case test); legit `[tool.*]` edits no longer false-block. | Shipped. | resolved (v0.9.0) |
| 2026-07-19 | improved | `env-uv` · `validate-python` · `/bootstrap` · `tabular` | Harvested dogfood theme #5 + wins. `env-uv`: isolated-GPU-env pattern + line-length-100 convention; `validate-python`/`bootstrap`: prose-budget note + ruff config registration; `tabular`: prove-on-synthetic-flip-to-real documented. | Shipped. | resolved (v0.9.0) |
| 2026-07-19 | open | `.claude/memory/` ↔ `docs/` sync | Dogfood theme #2 partially addressed (canonical-home guidance in `/intake`); no tool yet regenerates `docs/` snapshots from `.claude/memory/process/`. | Roadmap: a `/wrapup`-time (or hook) snapshot-regeneration step. | open |
| 2026-07-19 | missing | `/scaffold-retro` | The dogfood signal lived in a **downstream installed project's** `scaffold-journal.md` (dota2, git-untracked/local-only), but `/scaffold-retro` reads only *this* repo's journal. Harvesting it cross-project was ad-hoc (manual read + cluster). The most valuable dogfooding signal comes from installed projects, and there's no defined path to pull it back to the source scaffold. | `/scaffold-retro` could accept a path to an installed project's journal (or `/upgrade` could offer to surface it), so downstream friction reaches the source without hand-carrying. | open |
