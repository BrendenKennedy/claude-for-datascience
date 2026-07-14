---
description: One-time project bootstrap — generate the conf/ tree and the train/eval entry points the skills assume, then back-fill the placeholders that only become answerable once that code exists.
---

Create the project skeleton this scaffold's skills already describe. `/intake` picks the **stack**; this
picks the **shape**. Until it runs, `config-hydra` documents a `conf/` tree that doesn't exist, `training`
documents a `train.py` that doesn't exist, and "config over constants" governs nothing.

Run it **after** `/intake`, **once**, on a fresh scaffold. Throughout, `<pkg>` means the project's Python
package under `src/` (read it from `pyproject.toml` — do not invent one).

## 1. Interview (use the **AskUserQuestion** tool)

The skeleton's shape depends on the task; don't guess it. Ask, batched into one call:

- **CV task** — image classification *(default)* / object detection / semantic segmentation /
  **anomaly detection** (industrial defect finding). This decides the model, the loss, the metric, the label
  format, and — for anomaly detection — the entire data and training shape.
- **Dataset name** — the short slug used for `conf/dataset/<name>.yaml` and `data/<name>/`. This is the value
  `/intake` had to leave as a `<PLACEHOLDER>` in `config-hydra`, `datasets`, and `data-dvc`.
- **Model/backbone to start from** — e.g. `resnet18` (torchvision). For anomaly detection, ask which
  **method family** instead (see step 3b) — it changes whether there's a training loop at all.

If the user doesn't know the dataset yet, use `example` with `synthetic: true` and say so in the report — a
config group that runs on random tensors beats a placeholder that runs on nothing.

**If you can't ask** (non-interactive run, subagent, CI): don't stall and don't guess silently. Use the
defaults, and state loudly in the report that they were assumed, so the user can correct them before real
work lands on top.

## 2. Load the skills that own each piece — don't improvise

This command is a **sequencer, not a source of truth**. Before writing each file, load the skill that owns
it and follow it; if this command and a skill ever disagree, **the skill wins**:

| Writing… | Load first |
|---|---|
| `conf/` tree, the defaults list, `@hydra.main` | `config-hydra` |
| `train.py` — loop, seeding, checkpointing, AMP, resume | `training` |
| `eval.py` — deterministic eval, metric choice | `evaluation` |
| tracker calls inside both entry points | the tracking skill that `/intake` turned on |
| splits, label format, `SPLIT_SEED` | `datasets` |
| the tests that prove it works | `testing` |

## 3. Generate the skeleton

Every path below is named in a skill — this is the layout they refer to, so **changing a path here means
updating that skill in the same commit**.

```
conf/
  config.yaml              # defaults list + run-wide values. MUST declare: seed, epochs, experiment,
                           #   run_name, device, ckpt (null), resume (null), tracking.uri
  model/<backbone>.yaml
  optimizer/adamw.yaml     # + sgd.yaml
  scheduler/cosine.yaml    # + step.yaml — a real group, not loose keys in config.yaml
  dataset/<name>.yaml      # data_dir: ${oc.env:DATA_ROOT}/<name>; synthetic: true|false
src/<pkg>/
  env.py                   # load_env() — dotenv, called ONCE at each entry point's top (see below)
  seed.py                  # seed_everything(seed) — RNGs + cuDNN flags. THE one definition of "seeded".
  train.py                 # @hydra.main(config_path="../../conf", config_name="config")
  eval.py                  # own entry point; scores a checkpoint, never a tail of train
  data/
    splits.py              # SPLIT_SEED (fixed, NOT cfg.seed), split manifest read/write
    dataset.py             # torch Dataset + transforms (deterministic preprocess vs. random aug)
  models/
    factory.py             # build_model(cfg) -> nn.Module
models/                    # checkpoint outputs: best.pt, last.pt (data-versioned, not git)
```

Four keys in `config.yaml` are load-bearing and easy to miss:
- **`ckpt: null` AND `resume: null`** — Hydra is struct-mode: overriding a key the config never declared dies
  with `ConfigCompositionException`. Both are required — `ckpt=` by `eval.py` and `resume=` by the resume
  run (step 5). Declaring only `ckpt` is the classic mistake: everything passes until the resume step.
- **`device: cuda`** — the default *assumes* the GPU; entry points fall back to CPU when
  `torch.cuda.is_available()` is False. To force CPU on a GPU box, override `device=cpu`.
- **`tracking.uri: ${oc.env:...}`** — for MLflow this MUST be a database URI; 3.x raises on the old
  `./mlruns` file store. See `tracking-mlflow`.

**Something must actually load `.env`, or every `${oc.env:...}` is a lie.** Hydra's `oc.env` resolver reads
the *process* environment — it does **not** read `.env`. Without an explicit `load_dotenv()`, the config
silently depends on whatever the user happened to export in their shell, and works on one machine and not
the next. Emit `src/<pkg>/env.py` with a `load_env()` that calls `load_dotenv(override=False)` (real env
vars beat the file), and call it at the **top of each entry point** — never mid-logic, and never
`os.environ` from library code (config-over-constants).

**No data yet? Generate against tensors, via config — not a hardcoded branch.** The dataset group gets a
`synthetic: true` flag and `dataset.py` returns a random-tensor `Dataset` of the right shape. This keeps the
"no data" case *inside* the config system, so the same `train.py` runs on day one and on real data later —
flip one flag. It's also what makes step 5 runnable at all.

### The bootstrap rule about data: STRUCTURE, NOT A DATASET

**This command emits structure and contracts. It must not bake a specific dataset into the code.** The
skeleton outlives any one dataset — the same repo gets pointed at a new client, a new line, a new product
next month. A benchmark hardcoded into `dataset.py` becomes a tax paid forever.

So:
- **Emit a dataset *contract*, not a dataset.** One sample type (e.g. an `ADSample`/`Sample` dataclass) that
  every adapter returns. Everything downstream — the loop, the metrics, the tests — depends on the contract,
  never on a directory tree.
- **Express the layout as a *folder convention* whose names all come from config.** Directory names, file
  extensions, mask suffixes, an optional category level: config keys, not string literals in Python.
  A public benchmark (MVTec-AD, COCO, ImageFolder) is then just *one* `conf/dataset/<name>.yaml` — an
  example of the convention, not a privileged citizen.
- **Ship `conf/dataset/_template.yaml`** — the copy-me file for the next dataset, with the layout keys and
  the leakage rule spelled out. **Onboarding a dataset must cost one YAML file and zero Python.**
- **Only write a new adapter class when the data genuinely isn't folders** (a manifest CSV, a database, one
  big HDF5). That's the one case that should cost code, and it still returns the same contract type.
- **Never download a dataset during bootstrap.** Wire the layout, verify on `synthetic: true`, and leave the
  download to a human — it's slow, often large, and frequently license-encumbered (MVTec-AD, for instance,
  is CC BY-NC-SA: research-only, and a client deliverable is not research). Licensing is `governance`'s call,
  not yours.

If you find yourself writing the string `"train/good"` in a `.py` file, stop: that belongs in a YAML.

### 3b. If the task is anomaly detection, the shape changes — read this before writing code

Do **not** emit the classification skeleton with the labels renamed. Load `datasets` (one-class layout,
normal-only training) and `evaluation` (AUROC/AUPRO, never accuracy) first, then:

- **Data:** the fit set is **normal parts only**; defects appear **only** at test. `dataset.py` must not
  accept a defect into the fit split — assert it, and make it a test (a defect in the fit set silently
  teaches the model that the defect is normal; nothing crashes, the model just stops working).
- **Ask which method family**, because it decides whether `train.py` even has a loop:
  - **Gradient-trained** (autoencoder, student–teacher, normalizing-flow) — the normal `training` loop
    applies, but there is no label `y` and the loss is reconstruction/distillation error.
  - **Fit, not trained** (PaDiM, PatchCore, memory-bank/embedding methods) — **no backward pass at all**:
    run a frozen backbone over the normal set and store features. Do NOT fabricate an optimizer, scheduler,
    AMP, or an epoch loop to fill the template — emit a `fit.py` shape instead, and say so. The "checkpoint"
    is the fitted memory bank; still save it with config + git SHA.
- **Eval:** image-level AUROC + pixel-level AUROC/AUPRO, per defect type. If you emit `accuracy`, you have
  written the wrong eval — on a line running 99.5% good parts, calling everything "good" scores 99.5%.

## 4. Never clobber (but *do* extend)

Before **creating** a file: if it already exists and is non-empty, **stop and ask** — do not overwrite. This
command's job is to fill a void; the moment there's real code, the user's code wins.

That's a rule about *replacing* files, not touching them. Additive edits to pre-existing files are expected
and correct — do them, and report each: the smoke test (repoint determinism at `seed_everything`, add the
leakage test), the package `__init__.py` (a hello-world `main()` can go once real entry points exist), and
`pyproject.toml` (e.g. registering a pytest marker).

The line: **add to a file, never rewrite it out from under the user.** If an existing file's *logic* must
change to make the skeleton work, that's not a bootstrap edit — stop and ask. In particular: if a workaround
seems to require reaching into `os.environ` from library code, you have found a bug in a skill, not a license
to violate config-over-constants. Report it.

## 5. Prove it runs (don't just claim it)

Per `testing`, a green-looking command that never ran is worse than no test. Run these for real:

1. Lint/format, then the existing suite — it must still pass.
2. **Extend the smoke** so it covers the new code: point the determinism test at `<pkg>.seed.seed_everything`
   (so it exercises the helper the loop actually calls), and add a **leakage** test — split index sets are
   pairwise disjoint, and for anomaly detection, **zero anomalous samples in train**.
3. **Train, for real:** one epoch, CPU, `synthetic: true` if there's no data. Then **prove it wrote what it
   claims** — a tracker run exists with the resolved params + git SHA, and `models/best.pt` + `last.pt` are
   on disk. "Exit code 0" is not evidence. (Fit-not-trained AD: run the fit and confirm the memory bank
   persisted.)
4. **Eval, for real:** load the checkpoint back. Do not skip this because train passed — the train path never
   exercises `torch.load`, and reading a checkpoint back is where the failures live (`weights_only`,
   struct-mode keys, device mismatch). A skeleton whose checkpoints can't be *read* is not a working skeleton.
5. **Resume, for real:** re-run train from `last.pt`. It's the one path where a wrong `weights_only` or
   RNG-restore bug hides until the day you actually need it.

## 6. Back-fill the now-answerable placeholders

Re-run `grep -rn "<PLACEHOLDER" .claude/ CLAUDE.md README.md`. The hits are **two different families sitting
side by side in the same files** — read each, don't sweep:

- **Resolve now (code-dependent):** the dataset slug in `config-hydra` / `datasets` / the data-versioning
  skill, and any entry-point path. You just created the thing they were waiting on.
- **Leave (human-decision):** the data remote URL, `software-architect`'s architecture principles,
  `governance`'s policy domains, and the org-specific rules in `memory/policy/`. Don't invent values — a
  wrong policy is worse than a visible blank.

## 7. Report

- **Created:** each file, one line each. **Skipped:** anything that already existed (step 4).
- **Assumed:** any interview answer you defaulted because you couldn't ask.
- **Verified:** the exact commands from step 5 and their real output (test count, the tracker run id, the
  metric). Never claim a success you didn't observe.
- **Still needs you:** every remaining `<PLACEHOLDER`, plus any data-remote that isn't configured (without
  one, a git SHA does not pin recoverable data).

Then remind the user this is one-time — re-run only to reshape the skeleton, and never over real code.
