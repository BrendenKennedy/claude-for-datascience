# Session: dota2 dogfood refining patch (v0.9.0)

**Date:** 2026-07-19 · **Focus:** Harvest the `dota2-prediction-engine` dogfood friction and apply it as a scaffold refining patch

## Summary
Assessed the first full end-to-end dogfood of the scaffold — `dota2-prediction-engine` (scaffold
v0.7.0), which logged 18 `scaffold-journal.md` entries + a ranked Part II synthesis while running P1→P5
to an honest negative result. Harvested that signal into this repo and shipped it as **v0.9.0**: one new
methodology gate (predictive-signal screen) plus friction fixes across skills/commands/hooks. No
skill/command/agent added or removed — every change refines an existing component. All 7 `check-scaffold`
checks pass; guard-pyproject fix verified against a 9-case test.

## Changes & artifacts
- `.claude/skills/eda/SKILL.md` — new predictive-signal-screen section + triggers (the headline lesson)
- `PROCESS.md` — P2 signal-probe activity + **P3 exit-gate go/no-go**; version log → 0.3.0
- `.claude/commands/gate.md` — PASS now cascades to `roadmap.md` Now→Done
- `.claude/commands/intake.md` — mandatory un-skippable env-confirm; VC-scope question; skillOverrides session-boundary note
- `.claude/hooks/guard-pyproject.py` — DEP_PATTERN anchored on TOML table headers (kills `[tool.*]` false-blocks)
- `.claude/hooks/validate-python.py` + `.claude/commands/bootstrap.md` — prose-budget note + ruff line-length-100 registration
- `.claude/skills/env-uv/SKILL.md` — isolated-GPU-env pattern (RAPIDS/numba) + line-length-100 convention
- `.claude/skills/tabular/SKILL.md` — prove-on-synthetic-flip-to-real documented as the default
- `.claude/memory/{scaffold-journal.md,roadmap.md}` — dogfood themes + Done/Next; `CHANGELOG.md` [0.9.0]; `VERSION` → 0.9.0

## Key decisions
- Signal screen placed at **P3 exit gate** (last chokepoint before P4/P5 spend), not P4 — catch a weak ceiling before feature-build is sunk
- Screen's blind spots (adversarial targets, split-shift) named explicitly — baselines stay the true signal test, not superseded
- `docs/`↔`.claude` auto-sync **deferred to roadmap** — v0.9.0 ships canonical-home guidance; automation is follow-up
- skillOverrides-at-invocation is a **harness limitation** — documented, not "fixed"

## State
- Scaffold dev repo — its own PROCESS phase-state is the untouched template (N/A; no active DS project, no gate debt)
- v0.9.0 committed on branch `scaffold-refine-dota2-dogfood` @ `826914f`; landed to `main` + pushed to origin
- Known gap: GitHub v0.9.0 release/tag not cut (CHANGELOG + VERSION ready); `docs/` snapshot auto-sync open

## Follow-ups
- `docs/` snapshot auto-sync from `.claude/memory/process/` → `../roadmap.md`
- `/wrapup` × `memory` skill restatement drift watch → `../roadmap.md`
- Cut GitHub v0.9.0 release so installed projects (dota2 on v0.7.0) can `/upgrade`

## Related
- Source: `~/ML_projects/dota2-prediction-engine` — `reports/final_report.md` Part II + `.claude/memory/scaffold-journal.md`
- Prior: `2026-07-18-scaffold-self-assessment-loop.md` (built the meta-loop this session first exercises cross-project)
