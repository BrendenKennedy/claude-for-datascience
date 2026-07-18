# Changelog

All notable changes to claude-for-datascience. Format follows [Keep a Changelog](https://keepachangelog.com/);
versions follow [SemVer](https://semver.org/) per the stability contract in
[CONTRIBUTING.md](CONTRIBUTING.md). Installed projects can compare their
`.claude/scaffold-version` stamp against these entries to see what they're missing — and run
`/upgrade` to apply the delta safely.

> **Pre-1.0 renumbering (2026-07-18):** eight same-day releases (old v0.4.0–v0.11.0) were
> consolidated into the four feature releases below, before any 1.0 stability promise. Commits
> were never rewritten — only tags and release notes moved. If a `.claude/scaffold-version`
> stamp names an old number: 0.4 → 0.4 · 0.5/0.6/0.7 → 0.5 · 0.8/0.9 → 0.6 · 0.10/0.11 → 0.7 —
> and the stamp's commit **sha** remains the precise reference (`/upgrade`'s three-way logic
> keys on the sha, not the number).

## [Unreleased]

### Changed
- **CV is now a lane, not the default identity.** The scaffold is a *data-science* scaffold;
  archetypes (CV · tabular · time-series · LLM · …) are peer lanes flipped by `/intake`. The
  CV-specific skills (`annotation`, `pipelines`, `training` — the last flips for any
  neural-training archetype) moved from always-on to lane-gated; the always-on workflow tier is
  now the archetype-agnostic DS core (`datasets`, `eda`, `evaluation`, `statistics`,
  `visualization`, `notebooks`, `reporting`). `datasets` reframed: universal split/provenance
  discipline headline, CV formats as its CV section. Agents follow (`data-engineer`
  generalized; `ml-engineer` no longer preloads the now-gated `training` — reads it per
  `skillOverrides`). README/CLAUDE.md/tutorial identity surfaces updated; `/bootstrap` honestly
  notes its generated skeleton is currently the deep-learning shape.

### Added
- **`SessionStart` orientation hook (`.claude/hooks/session-orient.py`)** — the missing bookend to
  `/wrapup`. On a fresh session (`startup`/`clear`) it injects a compact "where are we" briefing —
  current phase, open gate debt, last session's focus + state + follow-ups, roadmap next — so a
  session never starts blind. CLAUDE.md is the only always-loaded file; live process state is not,
  so orientation otherwise depended on a skill surfacing by description match. No-ops silently
  pre-`/intake` (ad-hoc use isn't taxed). Supersedes the roadmap's "Stop-hook gate-debt warning":
  `Stop` fires per-turn, so gate-debt surfacing belongs at session start, not there.
- **"Finish before handing back" convention (CLAUDE.md)** — the per-response definition-of-done:
  the ask is actually satisfied, runtime code was exercised (not just written), decisions were
  recorded in their one home as you went, and a closing unit of work proactively offers `/wrapup`.
  The judgment half of the completion contract; the orientation hook is the mechanical half.
- **`docs/TUTORIAL.md`** — the hands-on first-project walkthrough (~30 min, runs on synthetic
  data): install → `/setup`'s four stages → bringing data → the daily rhythm (expect your first
  BLOCKED gate) → `/report` → maintenance.
- **`docs/REFERENCE.md`** — the human-browsable index of every skill, command, agent, and hook —
  **generated** from the frontmatter by `.claude/scripts/build-reference.py`; check-scaffold 6
  regenerates and diffs it, so the index structurally cannot drift (skips silently in installed
  projects, which don't receive `docs/`).

## [0.7.0] — 2026-07-18

The hardening & lifecycle release: an 11-dimension, adversarially-verified audit of the whole
scaffold (58 agents; 45 confirmed findings, 0 refuted) with every finding fixed — plus the
machinery that keeps installed copies current: `/upgrade`, a checker that catches the bug
classes that actually shipped, and a written stability contract.

### Added
- **`/upgrade`** — upgrades an installed project's scaffold: reads the `.claude/scaffold-version`
  stamp, summarizes the CHANGELOG delta first, then applies a three-way plan (ADD new files,
  REPLACE only files the project never modified — verified against the stamp sha — ASK on
  everything locally edited). Memory state, the skillOverrides profile, and filled placeholders
  are never clobbered; finishes with the scaffold check + `/skill-update --check`.
- **check-scaffold 2b** — every frontmatter block must `yaml.safe_load` (the class that shipped
  twice), descriptions must fit the 1,536-char truncation cap, and one-time commands/templates
  must carry `disable-model-invocation: true`. Negative-tested against a planted invalid file.
- **Stability contract** (CONTRIBUTING.md) — what breaking/additive/patch mean for a scaffold's
  interfaces; post-1.0, breaking changes ship migration notes and `/upgrade` does the mechanics.

### Fixed
- **Two invalid YAML frontmatters** (`/intake`'s colon-bearing description, `/report`'s double
  bracket `argument-hint`) — a regression of the exact bug class fixed in v0.2.x; all 50
  frontmatter blocks now `yaml.safe_load` clean.
- **`validate-bash` B1 hardened:** slash-suffixed home wipes (`~/`, `$HOME/`, `/home/<user>`
  targets of a recursive force-delete) now hard-BLOCK — they previously fell through to the ASK
  tier; verified by battery.
- **`run-leakage-tests.sh`:** pytest exit 5 (no tests matched `-k leakage`) no longer blocks
  session end as a spurious failure.
- **Shipped `.gitignore` now ignores `.env`** — the whole secrets model assumed this and the
  template path shipped without it.
- **Stale/broken references:** `_example`'s nonexistent `.claude/docs/` paths, intake's
  removed-placeholder MLflow bullet (repointed at the real experiment/run-name placeholders,
  plus a claim for the agents' `<PROJECT NAME>` token), policy/README's "scaffolded empty"
  claim (three domains ship), memory/README's missing `process/` row, templates/README's
  missing `aws-iam-policy.json` row + gitleaks mention, the training skill's wrong
  `config_path`/`config_name`, its resume snippet restoring only 2 of 4 saved RNG streams,
  serving's deprecated `on_event` (now lifespan), infra-aws's incomplete placeholder list,
  authoring-extensions' missing lane-gated tier, the memory skill's self-contradictory
  close-out order, `/setup` leaving the session note uncommitted, PROCESS.md's uncited
  templates + tracker hardcoding + worked-example leak, and a dozen smaller polish items
  (dangling colon, stale counts, mermaid double-label, agent boundary statements).
- **Release tags v0.4.0–v0.9.0 re-created as annotated** so `git describe` reports the true
  version (they were lightweight; v0.1–v0.3 were annotated).

## [0.6.0] — 2026-07-18

The infrastructure release: the scaffold manages the infrastructure under the pipelines —
through boundaries it cannot widen. AWS behind a least-privilege IAM role, Docker/Compose over
Kubernetes, self-hosted offline twins of every cloud piece, and one resource matrix recording
where everything is accessed.

### Added
- **`infra-aws`** (lane, off) — S3 + Redshift via the AWS CLI/boto3, acting through a dedicated
  least-privilege `claude-for-datascience` IAM role. Ships a starter policy
  (`.claude/templates/aws-iam-policy.json`): project-prefixed ARNs, read-heavy defaults, and an
  explicit `Deny` tier (bucket/cluster deletion, **all `iam:*`** — the role structurally cannot
  widen itself). S3-as-DVC-remote, UNLOAD/COPY through S3, cost awareness. SageMaker/EC2
  deferred until demand shows.
- **`containers`** (lane, off) — Docker + Compose: digest-pinned CUDA training images built from
  the lockfile, slim serving images that pull the model from the registry at start, GPU runtime,
  Compose for support services (MLflow + Postgres) with named-volume discipline, and
  `.dockerignore` as a security control. Kubernetes deliberately parked.
- **`validate-bash` A6/A7 tiers** — confirm dialogs on destructive AWS operations
  (bucket/cluster/instance deletion), all IAM mutation, and Docker state removal
  (`volume rm/prune`, `compose down -v`).
- **Security canon**: "Cloud credentials & the IAM boundary" — the agent acts through the scoped
  role, never a human admin profile; credentials stay in the credential store; CloudTrail +
  bucket versioning as part of least privilege.
- **`local-stack`** (lane, off; flips `containers` with it) — the self-hosted service catalog:
  **MinIO** as S3-compatible blob storage (endpoint-url wiring for DVC remotes / MLflow
  artifacts / boto3; credentials via `dvc remote modify --local`, never committed; per-bucket
  versioning), **CVAT** self-hosted for annotation (pinned release tag, shared-storage mount so
  datasets don't upload through the browser, export-to-COCO-immediately per the `annotation`
  discipline), **local Postgres** (init scripts so a fresh `compose up` reproduces the database
  shape, healthchecks), and the **extension matrix** (pgvector / TimescaleDB / PostGIS / Apache
  AGE — one prebuilt image per family; combining is a deliberate custom image), plus the
  backups-are-now-your-job rule.
- **Resource matrix** (`.claude/memory/process/resources.md`, shipped as a seed) — the single
  inventory of every service/store/endpoint a project touches: endpoint, env keys, credential
  *by reference* (never values), owner skill, backup status. The rule: provisioning anything
  updates the matrix **and `.env.example` in the same commit** — the two must agree. Written by
  the infra lanes (`infra-aws`, `local-stack`, `containers`, `serving`) and seeded by
  `/bootstrap`; CVAT's S3-compatible storage need is the motivating case (one MinIO bucket,
  recorded once, consumed by DVC and CVAT both).

## [0.5.0] — 2026-07-18

The full-lifecycle release: the scaffold becomes a general **data-science** platform. Archetypes
are lanes (tabular, time-series, LLM, SQL, serving — flipped by what you're building, so nobody
pays context for someone else's domain), and the workflow arc runs end to end: understand the
data first (`eda`), through modeling, to evidence-cited deliverables (`/report`). Ad-hoc asks
("plot this CSV") skip all process ceremony.

### Added
- **`tabular`** (lane, off) — sklearn-lane discipline: all preprocessing inside
  `Pipeline`/`ColumnTransformer` so CV can't leak, the Dummy→linear→boosting ladder,
  GroupKFold for entity-grouped rows, target-encoding and feature-importance traps,
  calibration, pipeline+model persisted as one artifact.
- **`timeseries`** (lane, off) — forecasting discipline: temporal-only splits with
  rolling-origin backtesting and embargo gaps, causal lag features, naive/seasonal-naive
  baselines as gates, MASE/sMAPE/pinball metrics, horizon as a P1 contract item.
- **`monitoring`** (lane, off — flip at first deploy) — PROCESS.md P7 made concrete:
  prediction logging, PSI/KS + embedding drift, the delayed-ground-truth loop,
  reference-window alert thresholds, retrain triggers, shadow eval before registry promotion.
- **`config-omegaconf`** (tool, off) — plain-OmegaConf composition without Hydra: schema-first
  merge, dotlist CLI overrides, `MISSING`, resolve-and-log. Closes `/intake`'s
  "no skill backs this choice" warning.
- **`eda`** — disciplined exploration: the first-look checklist, split-aware EDA (modeling
  decisions from train only), leakage-hunting, image-data EDA (sample grids, label overlays);
  findings land in P2's data-quality notes / risk register / feature dictionary, not a
  scrolled-past notebook.
- **`visualization`** — charts as evidence: chart-for-question mapping, honesty rules
  (bars-from-zero, shared axes, intervals + n on every estimate), perceptual rules
  (viridis-family, colorblind-safe), figures-as-code logged to the tracker, and the standard
  diagnostics set per task.
- **`statistics`** — what "evidence" means: seed variance as the noise floor (≥3 seeds,
  mean ± sd), bootstrap CIs, can-the-test-set-resolve-the-claim arithmetic, paired model
  comparisons, A/B test basics, multiple-comparisons discipline for slice scans.
- **`reporting` + `/report`** — deliverables (technical report, white paper, stakeholder
  summary, model card) assembled from the repo's own records: T1 problem statement, decision
  log, tracker runs, session notes. Every claim cites a run id; evidence gaps become
  `[TODO: evidence]`, never plausible numbers.
- **`sql`** (lane) — query-for-features discipline: push compute down, leakage-safe window
  frames (`1 PRECEDING`), join-grain checks, parametrized queries, snapshot what training eats.
- **`data-acquisition`** (lane) — cache-first raw layer, rate-limit budget math before pulling,
  backoff with jitter, incremental sync, boundary schema validation, ToS/robots as governance.
- **`serving`** (lane, flips at deploy) — batch-first bias, load-once-from-registry-alias
  endpoint shape, training-serving skew prevention, export parity checks, prediction logging as
  the `monitoring` precondition.
- **`wrangling`** (lane) — pandas without silent corruption: `validate=` on every merge +
  grain assertions, tz-aware UTC at the boundary, dtype traps, vectorization,
  order-is-not-a-contract.

### Changed
- `/intake`: lane skills flip from the step-0 archetype with no extra questions; the plain-
  OmegaConf option is now fully backed (the Hydra-shaped-skeleton caveat remains).
- `settings.json` `skillOverrides` + CLAUDE.md/README document the tool-vs-lane distinction.
- **Ad-hoc mode:** the `process` skill (and CLAUDE.md) now state that gates govern *project*
  work — "plot this CSV" is served directly with no phase ceremony, entering the process only
  when it starts informing project decisions.
- **`evaluation`:** fairness slices are required, not optional, when predictions affect people;
  gaps go in the model card, and slice findings pass multiple-comparisons discipline.

## [0.4.0] — 2026-07-18

The process-and-professionalism pass: the scaffold now runs on a phase-gate project framework
(`PROCESS.md`) with mechanical enforcement, tool skills are version-pinned with a maintenance
command, agents actually receive the skills their non-negotiables depend on, and the always-on
context cost was measured and roughly halved.

### Added
- **`PROCESS.md` (v0.2.0)** — hybrid project framework (CRISP-DM spine + TDSP roles/artifacts +
  CRISP-ML(Q) QA/monitoring + MLOps reproducibility + Lean kill criteria), amended with the gaps
  the sources miss: labeling/IAA gates, compute budgeting, and gate enforcement by structure
  (§3.8). Registered as the `process` governance domain; live state in `.claude/memory/process/`
  (project-definition, phase-state, risk-register, scope-ledger, decision-log).
- **`process` skill** (chassis) — the phase-gate operating loop + phase→skill map; deliberately no
  project-manager agent (gates need the user in the loop).
- **`annotation` skill** (workflow) — producing labels: spec-first loop, inter-annotator agreement
  (κ / IoU-matched), gold sets, label-error audits, pre-labeling circularity rules.
- **`/gate`** — evidence-based phase-gate review; records PASS or named gate debt in
  `phase-state.md`; refuses to advance on unchecked items.
- **`/setup`** — one-session orchestrator: git preflight → `/intake` → `/bootstrap` → `/gate` (P1)
  → `/wrapup`, checkpoint commit per stage.
- **`/intake` step 0** — the "what are we building?" project-definition interview: archetype +
  honest lane-fit, T1 problem statement, anti-pattern challenge pass (researches best practice
  before opining); writes `project-definition.md`, which pre-answers `/intake`/`/bootstrap` and
  doubles as P1 gate evidence.
- **Version-pinned tool skills + `/skill-update`** — every tool skill carries a `**Pinned:**` line
  tracking the locked dependency; `/skill-update` does drift checks, changelog research over the
  exact delta, empirical verification, and the pin bump. Git history is the archive of older skill
  versions.
- **New tool skills (gated, off):** `finetune-unsloth` (QLoRA/LoRA via Unsloth + TRL),
  `llm-eval` (harnesses, judge discipline, golden-prompt regressions — flips with unsloth),
  `hpo-optuna` (leakage-safe hyperparameter search). `tracking-mlflow` gains a Model Registry
  section (aliases over stages, promotion as a governed act).

### Changed
- **Context-efficiency pass** — all skill descriptions rewritten front-loaded (−31%; two exceeded
  the 1,536-char listing truncation cap and were silently losing their trigger words), CLAUDE.md
  cut 53%, `disable-model-invocation: true` on one-time commands and templates. Net always-on
  overhead ≈ halved. Budget rules documented in `authoring-extensions.md`.
- **Agent audit** — subagents have no Skill tool, so load-bearing always-on skills are now
  preloaded via frontmatter (`data-engineer` → datasets; `ml-engineer` → training;
  `eval-analyst` → evaluation+datasets); tool-gated skills are read on demand per
  `skillOverrides`. `ml-engineer` is tracker-agnostic; `code-reviewer` checks decision logs
  before flagging recorded choices; `software-architect` plans inside the scope-ledger contract;
  `eval-analyst` output is citable P5-gate evidence.
- `/wrapup` records the current phase + gate debt in every session note.

## [0.3.0] — 2026-07-15

The security pass: the threat model is now stated instead of implied, secrets have enforcement on
every path (agent writes, shell reads, human commits), and destructive operations get a
confirmation dialog that fires in every permission mode. Also the public-facing cleanup: the repo
is renamed, the README restructured, and the YAML frontmatter GitHub chokes on is fixed.

### Added
- **`guard-secrets.py` hook** (PreToolUse · Edit/Write) — blocks writes containing
  credential-shaped tokens (AWS/GitHub/Anthropic/OpenAI/Google/Slack/Stripe/HuggingFace keys,
  private-key blocks). `.env` itself is exempt: gitignored, and the one legitimate home for a real
  key. gitleaks added to the pre-commit template for the human-commit path.
- **`memory/policy/security.md`** — the security governance canon: the guardrails-vs-boundary
  threat model, secrets handling (rotate-don't-delete), what may be logged to trackers, egress
  rules, supply chain (`uv add` only, `weights_only=True` on downloaded checkpoints). Registered
  as the third domain in the `governance` skill's index with real trigger words.
- **Three-tier bash guard** — `validate-bash.sh` grows an ASK tier via `permissionDecision:
  "ask"`: recursive deletes, `git reset --hard` / `clean -f` / pathspec-checkout / `restore` /
  force-push / `branch -D` / history rewrites, `dvc gc`/`destroy`/`remove`, and deletion of ML
  assets (`data/`, `models/`, `*.pt`, `mlflow.db`, `uv.lock`, `.dvc`) now force a confirmation
  dialog **in every permission mode, including `bypassPermissions`**. BLOCK tier gains
  curl/wget-pipe-to-interpreter. Verified against a 41-case block/ask/allow battery during
  development (a verification exercise, not a shipped test suite).
- **README "Security model" section** — states the threat model plainly: hooks are guardrails
  against agent mistakes, the permission system is the boundary.

### Changed
- **Renamed: `claude-scaffold` → `claude-for-datascience`** (GitHub redirects the old URL). All
  in-repo references updated.
- **README restructured** — two-paragraph why/how abstract up top, then structured reference:
  quick start, lifecycle diagram, a five-row layer table, the tree; `/bootstrap` output and
  troubleshooting moved into collapsibles. 234 → ~170 lines.
- **`settings.json` deny list hardened** — `.env` shell-read denials (`cat .env` and variants),
  `Read(.env.local)`/`Read(.env.production)`; `.env.example` deliberately stays readable.

### Fixed
- **YAML frontmatter GitHub couldn't parse** — the six agent files and `commands/wrapup.md`
  carried single-line descriptions with a later `: `, which YAML reads as an illegal nested
  mapping ("Error in user YAML" banners on github.com). Folded to the `description: >` block style
  the skills already use; all 26 frontmatter blocks now parse.

## [0.2.0] — 2026-07-14

The "pro product" pass: two audits (newcomer onboarding + internals quality) drove down every
concentrated gap — unowned placeholders, an undocumented daily loop, a trap in the tracker
interview, and missing delivery files for the target project.

### Added
- **`tracking-wandb` skill** — W&B is now a fully backed `/intake` choice (init with the resolved
  config, `wandb.log(step=)`, Artifacts, offline mode + `wandb sync`). The "not authored yet"
  caveat now applies only to `config-omegaconf`, and is warned at selection time.
- **`.claude/templates/`** — delivery files `/bootstrap` instantiates into the target project:
  `.env.example` (the vars the entry points read), `.pre-commit-config.yaml` (ruff + nbstripout on
  human commits), and a project CI workflow (uv sync --frozen → ruff → pytest, the offline tier).
- **Three enforcement hooks** — `guard-pyproject.py` (deps go through `uv add`, not hand-edits),
  `guard-notebook-outputs.py` (.ipynb writes must be output-stripped), `run-leakage-tests.sh`
  (Stop hook: leakage tests run before the session ends; red blocks the stop).
- **`memory/reference/remote-gpu-workflow.md`** — the SSH/remote-GPU how: code by git, data by
  `dvc pull`, tmux, port-forwarding, GPU sanity.
- **check-scaffold check 5 (placeholder ownership)** — every file carrying a `<PLACEHOLDER>` must
  be claimed by `/intake` or `/bootstrap`; unclaimed blanks fail CI.
- **`/intake` template-mode cleanup** — repos created via "Use this template" are offered removal
  of the scaffold's own delivery files (installer, scaffold CI, scaffold README).
- CHANGELOG.md (this file).

### Changed
- **`testing/SKILL.md` is no longer a stub** — pre-filled with the scaffold's real defaults
  (`uv run pytest`, `uvx ruff`, `tests/` + `test_*.py`, monkeypatch + tiny CPU tensors); 17
  placeholders down to 4, each explicitly owned by `/bootstrap` §6.
- `/intake` interviews for the landing convention + commit trailer and fills the `memory` skill's
  close-out placeholders (which `/wrapup` runs against), and the `notebooks` gpu-host when remote.
- `/review` now dispatches the `code-reviewer` subagent (the ML/CV lens) instead of carrying a
  weaker duplicate checklist.
- README front door: plain-language problem statement, prerequisites, badges, a lifecycle diagram,
  a **Daily usage** section (skills auto-surfacing, `/review`, `/wrapup`), the post-`/bootstrap`
  project tree, and a Troubleshooting section.
- Skill-tier vocabulary settled everywhere: two tiers (always-on / tool-gated); the always-on tier
  has two groups, chassis (process) and workflow (CV/DS domain).

### Fixed
- `data-dvc`'s pipeline example showed a `--config configs/train.yaml` invocation `/bootstrap`
  never generates — now matches the Hydra shape (`conf/` as a dep; why `params:` doesn't apply).
- `install.sh` no longer ships stray `__pycache__/*.pyc` from a dirty working tree; the file filter
  is mirrored in `check-scaffold.sh` so a future mismatch fails CI.
- `settings.json` `permissions.allow` now covers what `/wrapup` (commit/branch/merge) and
  `/bootstrap` (uv, pytest, ruff) actually run — the two headline flows no longer prompt per step.
- CLAUDE.md no longer implies `.mcp.json` ships with the scaffold.

## [0.1.0] — 2026-07-14

First tagged release.

### Added
- The CV/DS `.claude/` scaffold: two-tier skills (chassis + workflow always on; tool skills gated by
  `skillOverrides`), five subagents, governance canon, session memory.
- `/intake` (stack) + `/bootstrap` (shape) one-time onboarding, including anomaly-detection
  ("fit-not-trained") and multi-stage-pipeline skeletons.
- `install.sh` — never-clobber drop-in installer; stamps `.claude/scaffold-version` into targets.
- CI: `check-scaffold.sh` self-consistency suite (docs↔disk drift, frontmatter, hook wiring,
  install idempotency) + shellcheck.
- MIT license.
