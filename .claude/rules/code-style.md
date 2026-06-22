# Code style

> **Rules** are modular guidance read *before* editing the files they govern. Keep each rule file
> short and specific. Reference them from CLAUDE.md so the agent knows when to pull each one in.
> Replace the contents below with this project's real conventions.

## General
- **Match the surrounding code.** Mirror the existing structure, naming, and comment density of the
  files you touch. Consistency beats personal preference.
- Prefer the **standard library / already-installed deps** over reinventing. Don't add a dependency
  without using the project's package manager (keep the manifest + lockfile in sync).
- Don't hand-format against the formatter — let the configured formatter/linter own style.

## Project idioms
- <e.g. config is env-driven; read settings in one place, never hard-code in business logic>
- <e.g. construct clients/connections through a single factory, not ad-hoc>
- <e.g. the project's error-handling, logging, or naming pattern>

## Formatting & linting
- <formatter command, e.g. `<fmt>`> · <linter command, e.g. `<lint> --fix`>
- <note if a hook runs these automatically on edited files>
