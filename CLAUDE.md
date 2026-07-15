# CLAUDE.md — index of this repo's `.claude/` config

This file is the **glossary / map** of the Claude configuration here. Beyond a short *Always-on
conventions* list (below), it holds **no deep project knowledge** — it only tells the agent *what lives
under `.claude/` and when to reach for each piece*. For the project itself (what it is, how to run it),
point at the skills and `README.md`. Keeping detail OUT of here is deliberate: it stays small, loads
every session, and never goes stale because the depth lives in the skills/docs it points to.

> This is **claude-for-datascience** tuned for **computer-vision & data-science** work. Two one-time setup steps,
> **in order**: **`/intake`** picks the *stack* (tracker, config, data versioning — flips the matching
> **tool skills** on/off via `settings.json` `skillOverrides` and fills the stack `<PLACEHOLDERS>`), then
> **`/bootstrap`** builds the *shape* (the `conf/` tree and `train.py`/`eval.py` the skills describe).
> Skip `/bootstrap` and the skills document a project that doesn't exist.

**How the config loads:**
- **Skills** auto-surface by their `description` — invoke the matching skill *before* acting in its
  domain (it carries the ground-truth detail). Skills come in **two tiers** (below).
- **Subagents** dispatch by `description` — delegate focused work to the right specialist.
- **Memory** (`.claude/memory/`) is the on-demand working-context store (sessions, roadmap, reference,
  policy) — its read/write process is the `memory` skill.
- **Commands** are slash commands — run them on request.
- **Hooks** run automatically around tool calls (wired in `settings.json`).

## Always-on conventions
The few rules that apply to essentially every change (fuller policy — code idioms, data/model governance
— via the `governance` skill → `.claude/memory/policy/`):
- **Match the surrounding code** — mirror its structure, naming, and comment density.
- **Reproducibility is non-negotiable** — seed every RNG, pin versions, and never let an experiment
  depend on un-recorded state. Determinism first; document any deliberate nondeterminism.
- **Never leak the eval set** — no fitting, tuning, or feature-selection on validation/test data; splits
  are defined once and respected everywhere. (See `datasets` + `data-governance`.)
- **Config over constants** — hyperparameters and paths flow through the config system, never hardcoded
  or read from the environment in the middle of business logic.
- **Deps via `uv`** — add with `uv add` so `pyproject.toml` + `uv.lock` stay in sync; never hand-edit
  (the `guard-pyproject` hook blocks dependency edits to enforce this).
- **Don't hand-format** — the `validate-python` hook (ruff) owns style. Note its bite: it runs
  `ruff check --fix` after *every* Edit/Write, so an import added in one edit and used in the next gets
  auto-deleted as F401 in between. Write the import and its usage in the **same** edit.

## Skills — `.claude/skills/<name>/SKILL.md`
Two tiers: **always-on** and **tool-gated**. The always-on tier has two groups — **chassis** (the
*process*: verify, remember, govern, parallelize) and **workflow** (the *CV/DS domain* work itself,
tool-agnostic). **Tool skills** are one-tool-each and gated on/off by `/intake` via `settings.json`
`skillOverrides` — swap MLflow for W&B, Hydra for plain OmegaConf, etc., without touching the
always-on skills that reference them.

**Chassis (always on):**
| Skill | Reach for it when… |
|---|---|
| `governance` | writing/editing code, changing the data/label model, touching data licensing/PII, or handling secrets/credentials/egress — the policy index + locate→load→apply→record protocol over `memory/policy/` |
| `testing` | running or writing a test, verifying a change, or claiming it works — the real commands + the tiny-data smoke (a forward pass on a fixture) for this repo |
| `memory` | recalling past work, recording a session, updating the roadmap, or branching/landing a unit of work |
| `wave-planning` | about to build with **more than one agent** — carve a settled goal into a collision-free wave manifest, batching on file-disjointness |

**Workflow skills (always on — tool-agnostic):**
| Skill | Reach for it when… |
|---|---|
| `datasets` | defining/splitting a dataset, label formats (COCO/YOLO/VOC), provenance, or guarding against leakage |
| `training` | writing or changing a train/fine-tune loop — config, checkpointing, resume, seeds/determinism |
| `evaluation` | building an eval harness, choosing metrics (mAP/IoU/PR), error analysis, or comparing runs |
| `pipelines` | composing models into a **cascade** (localize the item, then judge it) — the seam invariants: one shared split, stages as pure functions, error propagation, oracle-vs-end-to-end, joint thresholds |
| `notebooks` | working in Jupyter — keep logic in importable modules, thin notebooks, strip outputs |

**Tool skills (gated by `/intake` via `skillOverrides`):**
| Skill | Tool | Default |
|---|---|---|
| `env-uv` | uv (+ CUDA/torch version matrix, GPU sanity) | on |
| `tracking-mlflow` | MLflow experiment tracking | on |
| `config-hydra` | Hydra config composition + sweeps (on OmegaConf) | on |
| `data-dvc` | DVC data/model versioning | on |
| `tracking-wandb` | Weights & Biases experiment tracking | off (`/intake` flips) |
| `<skill-name>` | `<a tool you add>` | — |

## Subagents — `.claude/agents/<name>.md`
| Agent | Use for |
|---|---|
| `code-reviewer` | reviewing the current diff — correctness + quality, with an ML lens (device/dtype mismatches, tensor-shape bugs, seed handling, data leakage) |
| `software-architect` | planning a subsystem or weighing a design fork — read-only; pre-loaded with the project's ML-system architecture. Extends built-in `Plan` |
| `data-engineer` | building the data layer — dataset ingestion, label wrangling, splits, dataloaders, augmentation |
| `ml-engineer` | building/refactoring models + train/eval loops — architectures, losses, schedulers, checkpointing |
| `eval-analyst` | designing eval harnesses and doing error analysis — read-only; turns metrics into findings |
| `<agent-name>` | `<the focused work to delegate to it>` |

## Commands — `.claude/commands/<name>.md`
| Command | Does |
|---|---|
| `/intake` | one-time onboarding — interviews you for your stack, writes `skillOverrides`, fills `<PLACEHOLDERS>` |
| `/bootstrap` | one-time project skeleton — generates the `conf/` tree + `train.py`/`eval.py` the skills assume, then back-fills the placeholders that only become answerable once that code exists. Run **after** `/intake` |
| `/review` | review the current `git diff` for bugs + cleanups |
| `/wrapup` | close out the session — record → (commit) → land, as a checklist |
| `/<command>` | `<what it does>` |

## Hooks — `.claude/hooks/` (wired in `settings.json`)
| Hook | Event | Does |
|---|---|---|
| `validate-bash.sh` | PreToolUse · Bash | blocks recursive force-deletes of root/home (+ your project rules) |
| `guard-pyproject.py` | PreToolUse · Edit/Write | blocks dependency edits to `pyproject.toml` — deps go through `uv add`/`uv remove` |
| `guard-notebook-outputs.py` | PreToolUse · Edit/Write | blocks writing `.ipynb` files that carry cell outputs — notebooks commit clean |
| `guard-secrets.py` | PreToolUse · Edit/Write | blocks writes containing credential-shaped tokens (API keys, private keys) — secrets stay in `.env` |
| `validate-python.py` | PostToolUse · Edit/Write | runs `uvx ruff format` + `ruff check --fix` on edited `.py` files |
| `run-leakage-tests.sh` | Stop | runs any `leakage` tests before the session ends; a failure blocks the stop |

## Memory — `.claude/memory/`
The **data store** for cross-session working memory (refined summaries, **not** raw dumps) — pulled in on
demand, never auto-loaded. The read/write process is the `memory` skill; this is where the notes live.

| Path | Role |
|---|---|
| `.claude/memory/sessions/` | dated refined summaries of past sessions (`YYYY-MM-DD-<slug>.md`; start from `sessions/_template.md`) |
| `.claude/memory/reference/` | stable how-we-do-X notes that recur but don't warrant a full skill |
| `.claude/memory/roadmap.md` | living backlog / future scope / TODOs |
| `.claude/memory/policy/` | governance canon — `data-governance.md` (datasets/labels/licensing/PII), `model-governance.md` (reproducibility, model cards), `security.md` (secrets, logging/egress, threat model) |

## Other config
| Path | Role |
|---|---|
| `.claude/settings.json` | permissions + hook wiring + `skillOverrides` (the tool-skill profile `/intake` writes) |
| `.claude/scripts/` | helper scripts called by hooks/commands (README inside) |
| `.mcp.json` | MCP server wiring — **not shipped**; create at repo root if/when you add MCP servers |
