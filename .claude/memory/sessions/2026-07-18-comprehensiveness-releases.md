# Session: Comprehensiveness releases (v0.4.0 → v0.7.0) + public polish

**Date:** 2026-07-18 · **Focus:** make the scaffold serve a wide public DS audience, end to end

## Summary
Continuation of the process-and-efficiency session (same day, same conversation): four releases
turning the CV-tuned scaffold into an end-to-end DS platform. Versioned tool skills with a
maintenance command, an agent audit that made skill references real, lane-gating so breadth
doesn't cost context, the communication layer, and an end-to-end audit against what commercial
DS agents cover. Closed with public polish: CONTRIBUTING.md + a README walkthrough.

## Changes & artifacts
- **v0.4.0** — process framework + context-efficiency pass (see prior session note); agent audit
  (skill preloads via `skills:` frontmatter — subagents have no Skill tool); `**Pinned:**`
  version lines on tool skills + `/skill-update`; `finetune-unsloth`, `llm-eval`, `hpo-optuna`;
  MLflow Model Registry section
- **v0.5.0** — **lane skills** concept (workflow skills gated by archetype via the same
  `skillOverrides` as tools): `tabular`, `timeseries`, `monitoring` (flips at deploy);
  `config-omegaconf` authored (closed /intake's warning)
- **v0.6.0** — communication layer, always-on: `eda`, `visualization`, `statistics`,
  `reporting` + `/report` (drafts assembled from repo records; claims cite run ids; gaps become
  TODOs, never invented numbers)
- **v0.7.0** — end-to-end audit vs commercial DS agents + MLE-bench: `sql`,
  `data-acquisition`, `serving`, `wrangling` lanes; **ad-hoc mode** (gates govern project work;
  "plot this CSV" is served directly); fairness slices required in `evaluation`
- `reference/architecture-skills-vs-agents.md` — why skills stay in-context, no orchestrator
  agent; `skillListingBudgetFraction: 0.02` in settings
- `CONTRIBUTING.md` + README end-to-end walkthrough (public polish)

## Key decisions
- **No orchestrator/manager agent** — router-in-context beats per-hop delegation (cost,
  context loss, user cut out); recorded with revisit conditions in the reference note
- **Lane skills** — third gating notion (archetype-driven), keeps comprehensive ≠ expensive
- **Skill version archive = git history** — no parallel old copies; /skill-update commits
  record old→new pins
- **Ad-hoc exemption** — process ceremony scoped to project threads only
- Final scale: 31 skills (5 chassis, 10 always-on workflow, 16 gated), 6 agents, 9 commands

## State
- `main` at v0.7.0 + polish commit, all scaffold checks green, origin not yet pushed
- Description budgets: all skills ≤ ~1,100 chars, front-loaded; listing budget raised to 2%

## Follow-ups
- Push main + tags; create GitHub releases from CHANGELOG → `../roadmap.md`
- Run `/doctor`; watch skill-routing quality (sharpen, don't lengthen)
- Multi-archetype `/bootstrap` skeletons — the one remaining structural gap

## Related
- [2026-07-18-process-and-efficiency](2026-07-18-process-and-efficiency.md) (same conversation, first arc)
