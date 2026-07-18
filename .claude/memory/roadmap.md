# Roadmap

The living backlog: future scope, open threads, and TODOs. Sessions point their follow-ups here;
recall reads here for "what's next". Keep it pruned — check off or delete finished items.
Doubles as the scope **parking lot** (PROCESS.md §3.3): promotion into the v1 contract needs the
written gate + a decision-log line.

## Now / in progress
- Skill coverage for general-DS gaps (see 2026-07-18 session): LLM fine-tuning (unsloth, tool-gated),
  MLflow model registry (extend `tracking-mlflow`), monitoring/observability (deferred until first
  deploy — P7 covers concepts), tabular/classical-DS workflow skill (if archetype used)

## Next
- Release v0.4.0: VERSION + CHANGELOG for the process framework + efficiency pass
- Run `/doctor` to confirm the skill-listing budget post-rewrite
- Watch skill surfacing after the description rewrite; sharpen under-triggering descriptions

## Someday / maybe
- Multi-archetype `/bootstrap` skeletons (agent builds, tabular) — hook point exists in `/intake` step 0 lane-fit
- `config-omegaconf` skill (fast-follow noted in `/intake`)
- Stop-hook gate-debt warning (stricter §3.8 enforcement)

## Done (recent)
- Process framework integration + context-efficiency pass — 2026-07-18,
  [session note](sessions/2026-07-18-process-and-efficiency.md), commit `436a1f6`
