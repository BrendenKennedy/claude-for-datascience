# Changelog

All notable changes to claude-for-datascience. Format follows [Keep a Changelog](https://keepachangelog.com/);
versions follow [SemVer](https://semver.org/). Installed projects can compare their
`.claude/scaffold-version` stamp against these entries to see what they're missing.

## [0.5.0] — 2026-07-18

The comprehensiveness pass: the scaffold now serves the general-DS archetypes, not just CV.
Introduces **lane skills** — workflow skills gated by project archetype through the same
`skillOverrides` mechanism as tool skills, so users only pay context for the lanes they work in.

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

### Changed
- `/intake`: lane skills flip from the step-0 archetype with no extra questions; the plain-
  OmegaConf option is now fully backed (the Hydra-shaped-skeleton caveat remains).
- `settings.json` `skillOverrides` + CLAUDE.md/README document the tool-vs-lane distinction.

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
  curl/wget-pipe-to-interpreter. 41-case block/ask/allow battery.
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
