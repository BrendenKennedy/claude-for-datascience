---
name: notebooks
description: >
  How Jupyter notebooks are used in this repo — thin, exploratory, and reproducible, never the home of
  real logic. The rule that keeps them sane: **logic lives in importable modules under `src/`; notebooks
  import, they don't define.** Carries the concrete habits — launch the kernel from the uv env
  (`uv run jupyter lab`) so it matches `env-uv`, `%load_ext autoreload` so edits to `src/` land without a
  restart, strip outputs before committing (nbstripout / Clear All Outputs), never commit heavy outputs or
  data, and parametrize repeatable runs with papermill or `jupyter nbconvert --execute`. Reach for it
  before opening, editing, or committing a `.ipynb`, when a notebook's cells only work in a remembered
  order, or when exploratory code has grown big enough to promote into a module. Triggers: notebook,
  jupyter, jupyter lab, jupyter notebook, .ipynb, ipynb, kernel, nbstripout, nbconvert, papermill,
  autoreload, clear outputs, strip outputs, notebook diff, out-of-order cells, restart and run all,
  reproducible notebook, exploratory analysis, EDA, scratch notebook, promote notebook code.
---

# notebooks — thin, exploratory, reproducible Jupyter

> On-demand: load this before opening, editing, or committing a `.ipynb`, or when a notebook only runs in
> the order you happened to execute cells. Notebooks are for *looking*, not for *housing logic* — the moment
> code is reused or trusted, it belongs in a tested module.

## When this applies
Doing EDA or a quick experiment in Jupyter, wiring a notebook's kernel to the project env, committing a
`.ipynb`, turning a notebook into a repeatable run, or deciding whether a cell has outgrown the notebook.

## Keep logic in modules — notebooks import, they don't define
The single load-bearing rule. A notebook is a **thin driver**: it imports from `src/`, calls, and plots.
- Don't define models, losses, dataset/transform logic, or metric functions in a cell — put them in `src/`
  and `from src.<pkg> import ...`. A cell-defined function can't be tested, imported, or reviewed.
- When a cell's code gets reused (copied to a second notebook, or run twice), that's the signal to
  **promote** it: move a train/fine-tune step into the module the `training` skill owns, an eval/metric
  step into the module the `evaluation` skill owns, and dataset/split/label logic per the `datasets` skill.
  The notebook then imports the promoted function — same behavior, now tested and reproducible.

## Launch the kernel from the uv env
The kernel **must** be the project env, or imports and CUDA/torch silently differ from `uv run` scripts:
```bash
uv run jupyter lab          # or: uv run jupyter notebook
```
This matches the `env-uv` skill — same interpreter, same locked deps, same torch/CUDA wheel. If a notebook
can `import torch` but scripts can't (or vice-versa), the kernel isn't the uv env. Over SSH on a remote GPU
box, run the same command there and forward the port (`ssh -L 8888:localhost:8888 <PLACEHOLDER: gpu-host>`).

## Autoreload so `src/` edits land live
Put this at the top of the first cell so editing a module doesn't need a kernel restart:
```python
%load_ext autoreload
%autoreload 2
```
Now edit the function in `src/`, re-run the calling cell, and the new code runs — reinforcing "define in
the module, drive from the notebook."

## Strip outputs before committing
Committed outputs bloat the repo, leak data into diffs, and make every re-run a noisy diff. Strip them:
- **Automated (preferred):** `nbstripout` — a **git filter**, so it strips on `git add`/commit no matter who
  made the edit (a Claude `PostToolUse` hook would only catch the agent's). Installing it as a dev dep does
  **nothing on its own** — the filter must be activated, and it writes to `.git/config`, which is local and
  **not shared**, so *every clone must run it*:
  ```bash
  uv run nbstripout --install
  uv run nbstripout --status     # verify the filter is active — do this before trusting it
  ```
- **Manual:** Kernel → *Restart Kernel and Clear All Outputs* before saving.
- **Never commit** heavy outputs (rendered images, large tables), model weights, or dataset files from a
  notebook — data/model artifacts are versioned by the `data-dvc` tool skill, not git. See the data/PII
  rules in the `governance` skill (`.claude/memory/policy/`); don't restate them here.

## Parametrized / repeatable runs (optional)
When a notebook needs to run headless or across parameter sets, don't click through it:
- **`jupyter nbconvert --execute`** — run top-to-bottom, fail on any error (a reproducibility check in one):
  ```bash
  uv run jupyter nbconvert --to notebook --execute notebooks/<PLACEHOLDER: name>.ipynb --output out.ipynb
  ```
- **`papermill`** — same, but inject parameters into a tagged `parameters` cell for sweeps:
  ```bash
  uv run --with papermill papermill in.ipynb out.ipynb -p lr 3e-4 -p epochs 10
  ```
  For anything beyond a quick sweep, promote the logic to a `src/` entry point and drive it from the config
  system instead — that's the `training` / `config` path, not a notebook's.

## Gotcha
A notebook that only works in remembered execution order **is not reproducible** — hidden state from
deleted or out-of-order cells is a lie you'll ship. Before you trust or commit one: **Restart Kernel and Run
All** (or `nbconvert --execute`) so it proves it runs clean top-to-bottom. Anything you'd reuse gets
promoted into a tested module (`training` / `evaluation` / `datasets`), and outputs get stripped so the diff
stays legible. This is the repo's reproducibility convention applied to notebooks — see the *Always-on
conventions* in `CLAUDE.md`.
