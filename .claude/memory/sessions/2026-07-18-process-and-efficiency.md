# Session: Process framework + context-efficiency pass

**Date:** 2026-07-18 · **Focus:** integrate a phase-gate DS process framework; cut always-on context cost

## Summary
Integrated the user's hybrid PROCESS.md framework (CRISP-DM spine + TDSP/CRISP-ML(Q)/MLOps patches)
into the scaffold as a governed domain with mechanical gate enforcement, added annotation-ops and
setup orchestration, then ran a research-backed context-efficiency pass that fixed a real defect
(two skill descriptions exceeded the 1,536-char listing truncation cap and were silently losing
their trigger words).

## Changes & artifacts
- `PROCESS.md` (v0.2.0) — the framework + gap fixes: labeling/IAA gates, compute budgeting,
  gate enforcement (§3.8); "in this repo" notes delegate to MLflow, `/bootstrap`, roadmap, governance
- `.claude/skills/process/`, `.claude/skills/annotation/` — new always-on skills
- `.claude/commands/gate.md`, `setup.md` — evidence-based gate review; full setup orchestrator
  (git preflight → `/intake` → `/bootstrap` → `/gate` P1 → `/wrapup`, checkpoint commits)
- `.claude/commands/intake.md` — step 0: "what are we building?" definition interview (archetype +
  lane fit, T1, anti-pattern challenge w/ WebSearch) → `memory/process/project-definition.md`
- `.claude/memory/process/` — phase-state, risk-register, scope-ledger, decision-log seeds
- All 16 skill descriptions rewritten front-loaded (−31%; 0 over cap), `CLAUDE.md` −53%,
  `disable-model-invocation: true` on `/setup` `/intake` `/bootstrap` + templates;
  `authoring-extensions.md` documents the budget rules (1,536-char cap, ~1% listing budget)

## Key decisions
- No project-manager agent — gates need the user in the loop; main session wears the hat via `/gate`
- No data-manager agent — `data-engineer` extended with annotation-ops tooling instead
- `/define` folded into `/intake` step 0 (user call) — setup stays two commands + `/setup` wrapper
- Scope parking lot = `roadmap.md`; experiment log = MLflow — one home per artifact
- Description formula changed: front-load use case, triggers sharpest-first, ≤1,000 chars

## State
- Framework + efficiency pass landed on `main` (branch `session/2026-07-18-process-and-efficiency`,
  commit `436a1f6`, merge `2f5cbac`) · scaffold checks green · `/doctor` not yet run (user-side)

## Follow-ups
- Skill coverage gaps (user raised): LLM fine-tuning (unsloth), model registry, monitoring/observability,
  tabular DS → `../roadmap.md`
- Consider VERSION/CHANGELOG bump to 0.4.0 (release act, not taken this session)
- Watch skill surfacing quality post-rewrite; sharpen (not lengthen) any that under-trigger

## Related
- first recorded session in this repo
