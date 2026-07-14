---
description: Review the current diff by dispatching the code-reviewer agent (correctness + the ML/CV lens)
---

Review the current change in this repo — by **dispatching the `code-reviewer` subagent**, which carries
the full review lens (correctness plus ML/CV: device/dtype mismatches, tensor-shape bugs, data leakage,
seed handling, checkpoint/resume, metric sanity). Don't review inline; a hand-rolled checklist here
would just be a weaker copy of that agent.

1. Run `git diff` and `git diff --staged`. If **both** are empty, say so and stop — don't dispatch an
   agent at an empty diff.
2. Launch the `code-reviewer` agent on the change. Pass along anything the user scoped the review to
   (specific files, a stated concern like "check the device handling").
3. Relay its findings **verbatim** — grouped Blocking · Should-fix · Nit, each `path:line — problem →
   fix`, ending with its one-line verdict. Don't re-review, re-filter, or soften them.
