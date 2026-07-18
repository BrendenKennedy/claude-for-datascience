# CLAUDE.md — index of this repo's `.claude/` config

The map of the Claude configuration here: what lives under `.claude/` and when to reach for it.
Depth deliberately lives in the skills/docs this points to — skills auto-surface by description;
this file is for the always-on conventions and registration. Project details: the skills + `README.md`.

> **claude-for-datascience**, tuned for CV & data-science work. One-time setup, in order: **`/intake`**
> (the "what are we building?" interview → `memory/process/project-definition.md`, then the stack →
> `settings.json` `skillOverrides` + placeholders), then **`/bootstrap`** (builds the `conf/` tree +
> `train.py`/`eval.py` the skills assume — without it the skills document a project that doesn't
> exist). **`/setup`** runs the whole sequence + git checkpoints + the P1 `/gate` in one session.

## Always-on conventions
The rules that apply to essentially every change (fuller policy via the `governance` skill →
`.claude/memory/policy/`):
- **Work advances through phase gates** — the project runs on `PROCESS.md` (repo root); no forward
  phase transition without a passed `/gate` review recorded in `memory/process/phase-state.md`.
  The operating loop is the `process` skill.
- **Match the surrounding code** — mirror its structure, naming, and comment density.
- **Reproducibility is non-negotiable** — seed every RNG, pin versions, never let an experiment
  depend on un-recorded state; document any deliberate nondeterminism.
- **Never leak the eval set** — no fitting, tuning, or feature-selection on val/test; splits are
  defined once and respected everywhere (see `datasets` + `data-governance`).
- **Config over constants** — hyperparameters and paths flow through the config system, never
  hardcoded or read from the environment mid-logic.
- **Deps via `uv add`** — never hand-edit `pyproject.toml` (the `guard-pyproject` hook enforces).
- **Don't hand-format** — the ruff hooks own style. Bite: `ruff check --fix` runs after *every*
  Edit/Write, so write an import and its usage in the **same** edit or F401 deletes it between.

## Skills — `.claude/skills/<name>/SKILL.md`
Auto-surface by description (that text is the entire routing surface — see
`memory/reference/authoring-extensions.md` before adding one). Two tiers:
- **Always-on chassis:** `process` · `governance` · `testing` · `memory` · `wave-planning`
- **Always-on workflow (CV/DS):** `datasets` · `eda` · `annotation` · `training` · `evaluation` ·
  `statistics` · `visualization` · `pipelines` · `notebooks` · `reporting`
- **Gated** (`/intake` flips via `skillOverrides` — **tool** skills by stack choice, **lane**
  skills by archetype; all off unless flipped): tools — `env-uv` (on) · `tracking-mlflow` (on) ·
  `config-hydra` (on) · `data-dvc` (on) · `tracking-wandb` · `config-omegaconf` · `hpo-optuna`;
  lanes — `tabular` · `timeseries` · `finetune-unsloth` · `llm-eval` · `monitoring` (flips at
  first deploy). Tool skills carry a `**Pinned:**` version line — `/skill-update` keeps the facts
  true for the version the project actually runs.

## Subagents — `.claude/agents/<name>.md`
`code-reviewer` (diff review, ML lens) · `software-architect` (read-only planning, project
architecture pre-loaded) · `data-engineer` (data layer + annotation-ops tooling) · `ml-engineer`
(models + train/eval loops) · `eval-analyst` (read-only error analysis)

## Commands — `.claude/commands/<name>.md`
| Command | Does |
|---|---|
| `/setup` | full one-time setup: git preflight → `/intake` → `/bootstrap` → `/gate` (P1) → `/wrapup`, checkpoint commit per stage |
| `/intake` | one-time: project-definition interview, then stack → `skillOverrides` + placeholders |
| `/bootstrap` | one-time, after `/intake`: generate + prove the project skeleton, back-fill placeholders |
| `/gate` | phase-gate review per `PROCESS.md` §3.8 — evidence per item, records pass/debt in `memory/process/phase-state.md`, refuses to advance unchecked |
| `/skill-update` | sync a tool skill to the installed version — pin-vs-`uv.lock` drift check, changelog research, fact updates, pin bump; git history archives old versions |
| `/report` | draft a deliverable (report / white paper / stakeholder summary / model card) assembled from the repo's records — claims cite run ids; evidence gaps flagged, never filled |
| `/review` | review the current `git diff` for bugs + cleanups |
| `/wrapup` | close out the session — record note (incl. phase + gate debt) → (commit) → land |

## Hooks — `.claude/hooks/` (wired in `settings.json`)
| Hook | Event | Does |
|---|---|---|
| `validate-bash.sh` | Pre · Bash | blocks root/home wipes, `.env` reads, curl-pipe-to-shell; confirm dialog on destructive ops |
| `guard-pyproject.py` | Pre · Edit/Write | dependency edits go through `uv add`/`uv remove` |
| `guard-notebook-outputs.py` | Pre · Edit/Write | `.ipynb` must commit output-stripped |
| `guard-secrets.py` | Pre · Edit/Write | blocks credential-shaped writes — secrets stay in `.env` |
| `validate-python.py` | Post · Edit/Write | `ruff format` + `ruff check --fix` on edited `.py` |
| `run-leakage-tests.sh` | Stop | leakage tests gate session end |

## Memory — `.claude/memory/`
On-demand store, never auto-loaded; read/write process is the `memory` skill.
`sessions/` (dated summaries) · `reference/` (how-we-do-X notes, incl. `authoring-extensions.md` —
read it before extending `.claude/` — and `architecture-skills-vs-agents.md`, why skills stay
in-context and there's no orchestrator agent) · `roadmap.md` (backlog; doubles as the scope parking lot) ·
`policy/` (governance canon: `data-governance.md`, `model-governance.md`, `security.md`) ·
`process/` (live `PROCESS.md` state: `project-definition.md`, `phase-state.md`, `risk-register.md`,
`scope-ledger.md`, `decision-log.md`)

## Other config
`settings.json` (permissions + hooks + `skillOverrides`) · `scripts/` (hook/command helpers) ·
`.mcp.json` (MCP wiring — not shipped; create at repo root when needed)
