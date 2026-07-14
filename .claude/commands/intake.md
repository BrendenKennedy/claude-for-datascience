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
- **Config system** — Hydra *(default)* / plain OmegaConf / argparse.
- **Data versioning** — DVC *(default)* / git-lfs / none.
- **Baseline confirm** — the scaffold assumes **uv** for envs and an **NVIDIA GPU** (local or over SSH).
  Confirm that holds, and ask whether the GPU box is **aarch64/ARM** (e.g. a Grace-Blackwell / DGX Spark)
  — because ARM needs the ARM torch index placeholder filled in `env-uv`.

Capture the four answers before touching any file.

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
or data-versioning answer is "none", leave all keys in that group `off`. **Note:** `tracking-wandb` and
`config-omegaconf` skills may not be authored yet — writing their override is a harmless no-op until they
exist (fast-follow), so set them anyway.

## 3. Fill the answerable `<PLACEHOLDER>`s

Run `grep -rn "<PLACEHOLDER" .claude/ CLAUDE.md README.md` to list every one. Resolve **only** those the
interview now answers; leave the rest for the user. The answer-determined ones:

- **MLflow tracking URI** — `.claude/skills/tracking-mlflow/SKILL.md` (`set_tracking_uri(...)`). Fill if
  the user gave a URI; otherwise leave and flag it. Skip entirely if the tracker isn't MLflow.
- **DVC remote URL** — `.claude/skills/data-dvc/SKILL.md` (`dvc remote add -d storage ...`). Fill with the
  user's remote if given; else flag. Skip if data versioning isn't DVC.
- **ARM torch index** — `.claude/skills/env-uv/SKILL.md` (`<PLACEHOLDER: ARM torch index for your box>`).
  Fill **only if** the box is aarch64/ARM; on x86 leave the surrounding note as-is and note it's N/A.
- **Dataset path placeholders** — e.g. `data/<PLACEHOLDER: dataset dir>` / `<PLACEHOLDER: dataset_name>`
  in `data-dvc` and `datasets`. Fill if the user named a dataset/path during intake; otherwise leave.

Don't invent values. If an answer wasn't given, leave the placeholder and list it in the summary.

**Out of scope on purpose — say so, don't silently skip.** Two other classes of placeholder exist, and the
user WILL assume this command handled them unless step 4 tells them otherwise:
- **Code-dependent** (the `conf/` tree, the train/eval entry points, the seed helper, the dataset slug).
  These can't be filled until the project skeleton exists — that's **`/bootstrap`**, the next command.
- **Human-decision** (data-remote URL, `governance` policy domains, `software-architect` architecture
  principles, the org rules in `memory/policy/`). These need the user, not an agent. Leave and list them.

## 4. Report

Print a short summary:

- **Skills on:** the `skillOverrides` keys now `on`. **Skills off:** the rest.
- **Placeholders filled:** file + what each became.
- **Still needs you:** every `<PLACEHOLDER` left unresolved (from the step-3 grep), **split into the two
  classes above** — "will be filled by `/bootstrap`" vs. "needs your decision". A flat list reads as a
  to-do the user must do by hand, which is wrong and makes it look like intake failed.

Then: **this command is one-time** — re-run only to change stacks. **Next step is `/bootstrap`**, which
builds the skeleton (`conf/` + `train.py`/`eval.py`) that every skill's examples assume. Say this
explicitly — the scaffold is not usable until it's run.
