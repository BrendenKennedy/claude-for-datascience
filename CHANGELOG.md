# Changelog

All notable changes to claude-for-datascience. Format follows [Keep a Changelog](https://keepachangelog.com/);
versions follow [SemVer](https://semver.org/). Installed projects can compare their
`.claude/scaffold-version` stamp against these entries to see what they're missing.

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
