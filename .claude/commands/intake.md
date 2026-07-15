---
description: One-time onboarding — interview the user for their stack, write skillOverrides, and fill the answerable <PLACEHOLDER>s.
---

Onboard this scaffold to the user's actual stack. This is a **one-time** run: interview, flip the
tool-skill profile, resolve the placeholders the answers determine, then report. Work through the
steps in order; don't skip ahead.

## 1. Interview (use the **AskUserQuestion** tool)

Ask these — one question each, with the defaults marked. Batch them into a single AskUserQuestion call
where the tool allows:

- **Experiment tracker** — MLflow *(default)* / Weights & Biases / none.
- **Config system** — Hydra *(default)* / plain OmegaConf / argparse. **Warn at selection time** if
  the answer is plain OmegaConf: no dedicated skill backs it yet (fast-follow), so until it exists the
  project has no config skill — and `/bootstrap`'s skeleton is Hydra-shaped. Put the same warning in
  the option text itself, and restate it in the final report if chosen.
- **Data versioning** — DVC *(default)* / git-lfs / none.
- **Baseline confirm** — the scaffold assumes **uv** for envs and an **NVIDIA GPU** (local or over SSH).
  Confirm that holds, and ask whether the GPU box is **aarch64/ARM** (e.g. a Grace-Blackwell / DGX Spark)
  — because ARM needs the ARM torch index placeholder filled in `env-uv`. If the GPU is remote, also
  capture the SSH host alias (fills the `notebooks` port-forward example).
- **Landing convention** — merge branches into `main` locally *(default)* / push + open a PR. And:
  required commit trailer — none *(default)* / a custom line (e.g. a `Co-Authored-By`). Fills the
  `memory` skill's commit/land placeholders, which `/wrapup` runs against.

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

Exactly one tracker key and one config key should be `on`; the unchosen siblings go `off`. If the tracker
or data-versioning answer is "none", leave all keys in that group `off`. **Note:** the `config-omegaconf`
skill is not authored yet — writing its override is a harmless no-op until it exists (fast-follow), so set
it anyway, but the selection-time warning in step 1 is mandatory. (`tracking-wandb` IS authored — W&B is a
fully backed choice.)

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

Then: **this command is one-time** — re-run only to change stacks. **Next step is `/bootstrap`**, which
builds the skeleton (`conf/` + `train.py`/`eval.py`) that every skill's examples assume. Say this
explicitly — the scaffold is not usable until it's run.
