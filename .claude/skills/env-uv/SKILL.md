---
name: env-uv
description: >
  The Python environment via uv — creating/syncing the venv, adding pinned deps, and the part that
  actually bites in CV/ML: matching the torch + CUDA wheel to the machine's driver. Carries the
  exact commands: `uv sync` to materialize the locked env, `uv add` to add a dep (never hand-edit
  `pyproject.toml`), `uv run` to execute inside it, the `[[tool.uv.index]]` + `[tool.uv.sources]`
  pattern pinning PyTorch to the right CUDA build, the GPU sanity check, and the reproducibility
  rule (commit `uv.lock`; `uv sync --frozen` in CI). Load before installing anything, when
  `torch.cuda.is_available()` is False, or when setting up a new box. Triggers: uv, uv add, uv sync,
  uv lock, uv run, venv, install a package, add a dependency, pyproject.toml, uv.lock, torch,
  pytorch, cuda, cpu wheel, cuda not available, nvidia-smi, gpu not found, pin versions,
  reproducible environment.
---

# env-uv — the uv + CUDA environment workflow

> On-demand: load this before installing a package, standing up the env on a new machine, or when the
> GPU isn't visible to torch. It carries the commands that work **today** — don't reach for `pip install`
> or hand-edit `pyproject.toml`; both desync the lockfile.

## When this applies
Creating/syncing the env, adding or bumping a dependency, pinning the torch build to a CUDA version, or
debugging "why is `torch.cuda.is_available()` False".

## Create / sync the env
- **Materialize the locked env:** `uv sync` — creates `.venv/` and installs exactly what `uv.lock` pins.
  Use `uv sync --frozen` when the lock must not move (CI, a reproducible run).
- **Run inside it:** `uv run <cmd>` (e.g. `uv run python train.py`) — no manual `activate` needed.
- **New project from scratch:** `uv init` then add deps below.

## Adding & pinning deps (never hand-edit the manifest)
- **Add:** `uv add <pkg>` — resolves, installs, and writes both `pyproject.toml` and `uv.lock`.
- **Dev-only tools** (tests, notebooks, linters): `uv add --dev <pkg>`.
- **Bump / remove:** `uv add <pkg>@<ver>` · `uv remove <pkg>`.
- **Never** edit `pyproject.toml` dependencies or `uv.lock` by hand — that silently desyncs the two. This
  backs the always-on **"deps via `uv`"** convention.

## The torch + CUDA matrix (the sharp one)
PyTorch wheels are CUDA-specific; the default PyPI wheel often isn't the build you want. Pin the index:

```toml
# pyproject.toml — pick the cuXXX that matches the box's driver (see `nvidia-smi`)
[[tool.uv.index]]
name = "pytorch"
url = "https://download.pytorch.org/whl/cu124"
explicit = true

[tool.uv.sources]
torch = { index = "pytorch" }
torchvision = { index = "pytorch" }
```

Then `uv sync`. For a CPU-only box use `.../whl/cpu`. The wheel must match on **two** axes:
- **CUDA version** ≤ the driver's CUDA (from `nvidia-smi`, top-right) — a wheel newer than the driver is
  the usual cause of a silent CPU fallback or a load error.
- **CPU arch** — the default index serves `x86_64`; on **`aarch64`/ARM** boxes (Grace-Blackwell, GB10,
  Jetson) use the arch-appropriate index/source (`<PLACEHOLDER: ARM torch index for your box>`), not the
  x86 URL.

Developing over SSH on a remote GPU host? This all runs the same there — the env lives on that box; just
`uv run` inside the repo over the SSH session.

## GPU sanity check (run after any torch/CUDA change)
```bash
uv run python -c "import torch; print(torch.__version__, torch.cuda.is_available(), \
  torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU only')"
```
`False` with a GPU present ⇒ wheel/driver mismatch (above) or you're not inside the uv env (use `uv run`).

## Reproducibility
- **Commit `uv.lock`.** It's the reproducibility contract — the same lock reproduces the same env.
- Pin the Python version in `pyproject.toml` (`requires-python`) and, if the project needs it, a
  `.python-version` file so `uv` picks the same interpreter everywhere.
- CI / a "run it for real" invocation uses `uv sync --frozen` so a stale lock fails loudly instead of
  silently resolving something new.

## Gotcha
`uv run` is the boundary — a command that works in your shell but fails under the agent is almost always
running outside the env. Prefix with `uv run`. And if `pyproject.toml` and `uv.lock` ever disagree, you
hand-edited one: `uv sync` (or re-`uv add`) to reconcile, don't patch the lock.
