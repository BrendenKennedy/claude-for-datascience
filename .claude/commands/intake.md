---
description: One-time onboarding — the "what are we building?" definition interview (archetype, T1, anti-pattern challenge), then the stack interview: write skillOverrides and fill the answerable <PLACEHOLDER>s.
disable-model-invocation: true
---

Onboard this scaffold to the user's actual project and stack. This is a **one-time** run: define the
project, interview for the stack, flip the tool-skill profile, resolve the placeholders the answers
determine, then report. Work through the steps in order; don't skip ahead.

## 0. Project definition — "so what are we building?" (before any stack question)

The stack must serve the project, so the project gets defined first. **Load the `process` skill**;
the canon for what a definition contains is `PROCESS.md` P1 + template T1. This step is a
**conversation, not a form**. (Re-run of intake to change stacks? If
`.claude/memory/process/project-definition.md` already exists, skip to step 1 — revisit the
definition only on a genuine pivot, which also means a decision-log entry.)

- **Open question.** "What are we building?" in plain conversation — not AskUserQuestion. Let the
  user talk; follow up until you can state in your own words what is produced, for whom, and what
  decision it changes. Reflect it back and get a "yes, that's it."
- **Classify the archetype** (AskUserQuestion once you have context): computer vision · classical
  DS on structured/tabular data · time-series/forecasting · NLP / LLM application · AI agent build ·
  autonomous systems/robotics · analytics & reporting. **Be honest about lane fit, out loud:** this
  scaffold is CV/DS-tuned. The chassis (`process`, `memory`, `governance`, `testing`,
  `wave-planning`) and the PROCESS.md phases are archetype-agnostic — an agent build still has data
  discovery, baselines, and eval — but the workflow skills (`datasets`, `training`, `evaluation`,
  `pipelines`, `annotation`) and `/bootstrap`'s skeleton are CV-shaped. State exactly what fits and
  what doesn't, and ask whether to proceed with the gaps recorded — never silently pretend the CV
  skills cover an out-of-lane build.
- **Fill T1 conversationally:** prediction target · consumer & the decision it changes ·
  constraints (deadline, data access, budget, and the **compute math** — est. cost of one training
  run × runs implied, vs. hardware and deadline) · success metric + threshold + the baseline it
  must beat · non-ML benchmark · **kill criteria** · feasibility notes. An unanswerable field is
  recorded as an open question — an honest blank beats an invented answer; the P1 gate will catch it.
- **The challenge pass — the reason this step exists.** Before anything is set in stone, examine
  the plan for anti-patterns: no baseline / straight to the deep model · metric mismatch (accuracy
  on imbalance, no calibration where probabilities are consumed) · leakage baked into the framing
  (inputs not actually available at prediction time) · data assumed rather than verified
  (licensing/ToS, access) · no kill criteria / unfalsifiable goal · scope with no v1 contract.
  Where you're unsure of current best practice — or the archetype is fast-moving (LLM apps, agents)
  — **WebSearch before opining**; don't challenge from stale memory. Then push back specifically:
  *"are you sure about X? The typical approach is Y because Z — here's what I found."* The user
  decides; your job is making sure it's a decision, not a default. Every challenge that changes (or
  deliberately doesn't change) the plan gets a line in `.claude/memory/process/decision-log.md`,
  alternatives included.
- **Write the definition doc** at `.claude/memory/process/project-definition.md`, sections:
  **Archetype & lane fit** (incl. skill/skeleton gaps) · **Problem definition (T1)** ·
  **Challenged decisions** (one line each, pointing at the decision log) · **Setup implications**
  (suggested pre-answers for the stack interview below and for `/bootstrap`'s interview — task
  type, dataset slug, backbone/method family) · **Open questions**. Seed the v1 contract into
  `scope-ledger.md` and framing-level risks into `risk-register.md` — they were just discussed;
  don't make the user restate them at the first `/gate`.

## 1. Stack interview (use the **AskUserQuestion** tool)

Ask these — one question each, with the defaults marked. Batch them into a single AskUserQuestion call
where the tool allows. The definition doc's **Setup implications** may already answer some:
present those as the pre-selected option and confirm, don't re-ask blind:

- **Experiment tracker** — MLflow *(default)* / Weights & Biases / none.
- **Config system** — Hydra *(default)* / plain OmegaConf (backed by `config-omegaconf`; warn that
  `/bootstrap`'s skeleton is Hydra-shaped, so its entry points need adapting to that skill's
  pattern) / argparse (no skill backs argparse; config-over-constants still applies).
- **Data versioning** — DVC *(default)* / git-lfs / none.
- **Baseline confirm** — the scaffold assumes **uv** for envs and an **NVIDIA GPU** (local or over SSH).
  Confirm that holds, and ask whether the GPU box is **aarch64/ARM** (e.g. a Grace-Blackwell / DGX Spark)
  — because ARM needs the ARM torch index placeholder filled in `env-uv`. If the GPU is remote, also
  capture the SSH host alias (fills the `notebooks` port-forward example).
- **Landing convention** — merge branches into `main` locally *(default)* / push + open a PR. And:
  required commit trailer — none *(default)* / a custom line (e.g. a `Co-Authored-By`). Fills the
  `memory` skill's commit/land placeholders, which `/wrapup` runs against.
- **LLM fine-tuning** — ask **only if** the definition doc's archetype involves LLM work: Unsloth
  *(default when applicable)* / none. Flips `finetune-unsloth` **and** `llm-eval` together (a
  fine-tune you can't measure isn't a deliverable).
- **HPO** — Hydra multirun grids only *(default)* / Optuna (continuous spaces, pruning, resumable
  search). Flips `hpo-optuna`.

Capture the five answers before touching any file.

## 2. Write `settings.json` `skillOverrides`

Edit `.claude/settings.json` — set each key to `"on"` or `"off"` from the answers. Only these keys:

| Key | On when… |
|---|---|
| `env-uv` | always `on` (baseline) |
| `tracking-mlflow` | tracker = MLflow |
| `tracking-wandb` | tracker = W&B |
| `config-hydra` | config = Hydra |
| `config-omegaconf` | config = plain OmegaConf |
| `data-dvc` | data versioning = DVC |
| `finetune-unsloth` | LLM fine-tuning = Unsloth |
| `llm-eval` | LLM fine-tuning = Unsloth (flips with it) |
| `hpo-optuna` | HPO = Optuna |
| `tabular` | archetype = classical DS on structured data |
| `timeseries` | archetype = time-series / forecasting |
| `wrangling` | flips with `tabular` or `timeseries` (the pandas-heavy lanes) |
| `sql` | the definition doc says data lives in a database / warehouse |
| `data-acquisition` | the definition doc says data is pulled from APIs or scraped |
| `serving` | the project ships a scorer/endpoint — usually flipped at P6, not at intake |
| `monitoring` | the project is deploying — usually flipped later, at P7, not at intake |

Exactly one tracker key and one config key should be `on`; the unchosen siblings go `off`. If the tracker
or data-versioning answer is "none", leave all keys in that group `off`. **Lane skills flip from the
archetype in the definition doc (step 0) — no extra question needed:**

## 3. Fill the answerable `<PLACEHOLDER>`s

Run `grep -rn "<PLACEHOLDER" .claude/ CLAUDE.md README.md` to list every one. Resolve **only** those the
interview now answers; leave the rest for the user. The answer-determined ones:

- **MLflow tracking URI** — `.claude/skills/tracking-mlflow/SKILL.md` (`set_tracking_uri(...)`). Fill if
  the user gave a URI; otherwise leave and flag it. Skip entirely if the tracker isn't MLflow.
- **W&B project name** — `.claude/skills/tracking-wandb/SKILL.md` (`wandb.init(project=...)`). Fill if
  the user named a project; otherwise leave and flag it. Skip entirely if the tracker isn't W&B.
- **DVC remote URL** — `.claude/skills/data-dvc/SKILL.md` (`dvc remote add -d storage ...`). Fill with the
  user's remote if given; else flag. Skip if data versioning isn't DVC.
- **ARM torch index** — `.claude/skills/env-uv/SKILL.md` (`<PLACEHOLDER: ARM torch index for your box>`).
  Fill **only if** the box is aarch64/ARM; on x86 leave the surrounding note as-is and note it's N/A.
- **Dataset path placeholders** — e.g. `data/<PLACEHOLDER: dataset dir>` / `<PLACEHOLDER: dataset_name>`
  in `data-dvc` and `datasets`. Fill if the user named a dataset/path during intake; otherwise leave.
- **`memory` skill commit/land placeholders** — `.claude/skills/memory/SKILL.md` (the commit-trailer
  line and the landing-convention line). The landing-convention question always answers these — the
  defaults ("merge locally", "no trailer") resolve them too, so this bullet always completes; never
  leave them blank, because `/wrapup` runs the memory skill verbatim and hits them.
- **`notebooks` gpu-host** — `.claude/skills/notebooks/SKILL.md` (`ssh -L ... <PLACEHOLDER: gpu-host>`).
  Fill **only if** the GPU box is remote (from the baseline confirm); if local, leave the example
  as-is and note it's N/A — same pattern as the ARM torch index.

Don't invent values. If an answer wasn't given, leave the placeholder and list it in the summary.

**Out of scope on purpose — say so, don't silently skip.** Two other classes of placeholder exist, and the
user WILL assume this command handled them unless step 4 tells them otherwise:
- **Code-dependent** (the `conf/` tree, the train/eval entry points, the seed helper, the dataset slug).
  These can't be filled until the project skeleton exists — that's **`/bootstrap`**, the next command.
- **Human-decision** (data-remote URL, `governance` policy domains, `software-architect` architecture
  principles, the org rules in `memory/policy/`). These need the user, not an agent. Leave and list them.

## 4. Template-mode cleanup (only when the repo IS the scaffold)

Two ways this scaffold arrives: `install.sh` into an existing project (leaves a `.claude/scaffold-version`
stamp), or GitHub's **"Use this template"** (the repo *is* a copy of claude-for-datascience — no stamp, and it
carries the scaffold's own delivery files, which are about the scaffold, not the user's project).

**Detect template mode:** `install.sh` **and** `.claude/scripts/check-scaffold.sh` exist at repo root
**and** there is no `.claude/scaffold-version`. If that doesn't hold, skip this step silently.

If detected, **offer** the cleanup (AskUserQuestion — never do this silently; it deletes files):

- Delete `install.sh` + `VERSION` (this repo won't be installing itself anywhere), and write the
  scaffold's version + SHA into `.claude/scaffold-version` so the provenance survives the cleanup.
- Replace `.github/workflows/ci.yml` (the *scaffold's* self-consistency CI — it would fail against a
  real project) with `.claude/templates/project-ci.yml`.
- Replace `README.md` (the scaffold's own) with a minimal project stub: project title, quick start,
  and a "configured by claude-for-datascience vX" line. Keep `CHANGELOG.md` only if the user wants one.
- Optionally delete `.claude/scripts/check-scaffold.sh` — it checks the scaffold, not the project.

If declined, note in the report that the scaffold's own delivery files are still in place.

## 5. Report

Print a short summary:

- **Skills on:** the `skillOverrides` keys now `on`. **Skills off:** the rest.
- **Placeholders filled:** file + what each became.
- **Still needs you:** every `<PLACEHOLDER` left unresolved (from the step-3 grep), **split into the two
  classes above** — "will be filled by `/bootstrap`" vs. "needs your decision". A flat list reads as a
  to-do the user must do by hand, which is wrong and makes it look like intake failed.

Then: **this command is one-time** — re-run only to change stacks (the definition step is skipped on
re-runs; see step 0). **Next step is `/bootstrap`**, which builds the skeleton (`conf/` +
`train.py`/`eval.py`) that every skill's examples assume — it reads the definition doc's Setup
implications, so its interview should mostly be confirmation. Say this explicitly — the scaffold is
not usable until it's run. After `/bootstrap`: run **`/gate`** — the definition doc is most of P1's
gate evidence, so the review should be quick.
