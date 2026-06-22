---
description: Review the current working-tree diff for bugs and cleanups
---

Review the current change in this repo.

1. Run `git diff` and `git diff --staged` to see what changed. If nothing is staged or unstaged,
   say so and stop.
2. Read enough surrounding context to judge each hunk correctly.
3. Report findings grouped by severity — **Blocking · Should-fix · Nit** — each as
   `path:line — problem → fix`. Verify each finding is real before reporting it.
4. End with a one-line verdict.

Keep it to the diff. Don't review unchanged code, and don't invent findings if the diff is clean.
