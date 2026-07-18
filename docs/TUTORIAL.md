# Tutorial — your first project on the scaffold

A hands-on path from empty directory to your first gated, tracked, reported project. Everything
here runs for real — the skeleton trains on synthetic data before you have a single image, so
you can follow along with nothing prepared. Time: ~30 minutes of interaction.

## 0. What you need

[Claude Code](https://claude.com/claude-code) · `git` · [`uv`](https://docs.astral.sh/uv/) ·
optionally an NVIDIA GPU (everything works CPU-only on synthetic data). No dataset required yet.

## 1. Install

```bash
git clone https://github.com/BrendenKennedy/claude-for-datascience.git ~/dev/claude-for-datascience
mkdir my-project && cd my-project && git init
~/dev/claude-for-datascience/install.sh .
```

The installer copies `.claude/` (skills, agents, commands, hooks), `CLAUDE.md` (the index the
agent reads every session), and `PROCESS.md` (the phase-gate framework). It never overwrites
existing files and stamps `.claude/scaffold-version` so `/upgrade` can serve you later.

## 2. `/setup` — one guided session

Open Claude Code in the project and run `/setup`. Expect four stages, each ending in a
checkpoint commit:

1. **The definition interview** — it opens with *"what are we building?"* and it will push back:
   name accuracy as your metric on imbalanced data and it will challenge you with the standard
   practice and its reasoning. Answer honestly, including "I don't know" — unknowns become
   recorded open questions, not invented answers. Output: `memory/process/project-definition.md`.
2. **The stack interview** — tracker (MLflow default), config (Hydra default), data versioning
   (DVC default). Your archetype from stage 1 flips the matching *lane* skills on; everything
   else stays off and costs you nothing.
3. **`/bootstrap`** — generates the skeleton (`conf/` tree, `train.py`, `eval.py`, seed helper,
   tests) and then **proves it**: a real train run on synthetic data, an eval that re-loads the
   checkpoint, a resume. If it reports success, it observed success.
4. **The P1 gate** — `/gate` walks Phase 1's exit checklist against the definition doc as
   evidence. Unanswered items become named *gate debt*, not silent passes.

## 3. Bring your data

Point the agent at your data in plain language — *"here's my dataset at ~/data/widgets, split
it"* — and watch the skills surface: `datasets` enforces the split-once/group-split/leakage
rules for every archetype, `eda` runs the first-look checklist (and files what it finds into
the data-quality notes and risk register), and your lane's skills carry the specifics —
`annotation` if you're producing CV labels (spec first, then a measured agreement pilot),
`tabular`/`timeseries`/`sql` in theirs.

Quick questions need no ceremony: *"plot the class balance"* is served directly — gates govern
project work, not curiosity.

## 4. The daily rhythm

Work conversationally; the skills load themselves. Three habits carry the system:

- **`/review`** before committing — the diff gets the ML lens (device/dtype, shapes, leakage,
  seeds).
- **`/wrapup`** when you stop — the session note + roadmap update that lets tomorrow's session
  answer *"what did we decide about the crop padding?"*
- **`/gate`** at phase boundaries — expect your first **BLOCKED** verdict early (typically P2,
  on the label audit). That's the system working: the debt is named, you keep working the
  phase, and nothing slides forward silently.

Training runs are seeded, config-snapshotted, and tracked without you asking — that's the
`training` + tracker skills' standing conventions. When you think you've improved something,
the `statistics` skill's seed-variance check is what separates a result from a lucky seed.

## 5. Ship the story

`/report stakeholder` (or `report`, `whitepaper`, `model-card`) assembles a deliverable from
the repo's own records — problem statement, decision log, tracker runs. Every number cites a
run id; anything it can't back becomes `[TODO: evidence]` rather than a plausible guess. If
you deploy, the `serving` and `monitoring` lanes flip on at that point, not before.

## 6. Keep it current

- **`/skill-update`** after you deliberately upgrade a tool — syncs that skill's facts to the
  version you actually run (`--check` shows drift).
- **`/upgrade`** after a new scaffold release — reads your version stamp, shows the CHANGELOG
  delta, and applies it without touching your edits or state.
- After shipping, run the **retro** (PROCESS.md Part V): edit PROCESS.md itself with what the
  gates caught and missed, and bump its version. The process improving per project is the
  point of the whole system.

## Where to go deeper

[REFERENCE.md](REFERENCE.md) — every skill/command/agent/hook, one line each ·
[PROCESS.md](../PROCESS.md) — the framework and its lineage ·
[CONTRIBUTING.md](../CONTRIBUTING.md) — extending the scaffold, and the stability contract.
