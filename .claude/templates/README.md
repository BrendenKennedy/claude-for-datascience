# templates — delivery files for the TARGET project

These are not scaffold config — they're starter files for the *project being scaffolded*.
`/bootstrap` (§3d) copies each to its destination and fills the marked slots; never-clobber applies.

| Template | Destination in the target | What it is |
|---|---|---|
| `dot-env.example` | `.env.example` | the env vars the entry points read (copy to `.env`, fill in) |
| `pre-commit-config.yaml` | `.pre-commit-config.yaml` | ruff + nbstripout on human commits (`uvx pre-commit install`) |
| `project-ci.yml` | `.github/workflows/ci.yml` | offline tier in CI: uv sync --frozen → ruff → pytest |
