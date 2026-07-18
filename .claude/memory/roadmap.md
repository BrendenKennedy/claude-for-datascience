# Roadmap

The living backlog: future scope, open threads, and TODOs. Sessions point their follow-ups here;
recall reads here for "what's next". Keep it pruned — check off or delete finished items.
Doubles as the scope **parking lot** (PROCESS.md §3.3): promotion into the v1 contract needs the
written gate + a decision-log line.

## Now / in progress
- (nothing active — the next real project run through `/setup` drives the backlog)

## Next
- Run `/doctor` to confirm the skill-listing budget post-rewrite
- Watch skill surfacing after the description rewrite; sharpen under-triggering descriptions

## Someday / maybe
- Multi-archetype `/bootstrap` skeletons (tabular/timeseries/LLM entry points — the skills now exist; the skeleton is still Hydra+CV-shaped)
- Causal inference skill (observational methods beyond A/B — DoWhy/propensity) — when demand shows
- Big-data escalation skills (polars/duckdb/spark) — when demand shows
- Kubernetes manager, SageMaker/EC2 surface for `infra-aws`, GCP/Azure lanes — parked on demand (AWS S3+Redshift + Docker/Compose shipped in v0.8.0)
- Data-validation tool skill (pandera/great-expectations)
- Stop-hook gate-debt warning (stricter §3.8 enforcement)

## Done (recent)
- Release v0.8.0: infrastructure pass (infra-aws + IAM boundary template, containers, hook tiers) — 2026-07-18
- Pushed to origin; GitHub releases v0.4.0–v0.7.0 created from CHANGELOG — 2026-07-18
- Release v0.7.0: end-to-end pass (sql, data-acquisition, serving, wrangling lanes; ad-hoc mode; fairness slices) — 2026-07-18
- Release v0.6.0: communication layer (eda, visualization, statistics, reporting + /report) — 2026-07-18
- Release v0.5.0: lane skills (tabular, timeseries, monitoring) + config-omegaconf — 2026-07-18
- Release v0.4.0 (process framework, efficiency pass, agent audit, versioned tool skills,
  llm-eval + hpo-optuna) — 2026-07-18
- `finetune-unsloth` (tool-gated) + MLflow Model Registry section + version pins on all tool
  skills + `/skill-update` — 2026-07-18
- Process framework integration + context-efficiency pass — 2026-07-18,
  [session note](sessions/2026-07-18-process-and-efficiency.md), commit `436a1f6`
