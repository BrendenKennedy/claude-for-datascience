# Contributing

Contributions welcome — skills, agents, commands, hooks, and fixes to any of them. This repo is
itself the artifact: the bar for what goes in is the same discipline the scaffold teaches.

## Before you write anything

Read **`.claude/memory/reference/authoring-extensions.md`** — it is the authoring canon for all
four extension types (skills, agents, commands, hooks): file locations, frontmatter contracts,
and the conventions that bite. The short version of the rules that reject PRs:

- **Earn the surface.** Every always-on skill's description is paid for in every session by every
  user. New knowledge must either fit an existing skill, gate behind a tool/lane override, or
  displace something weaker. "Might be useful" is the parking lot (`roadmap.md`), not a merge.
- **Descriptions are front-loaded and budgeted.** ≤ ~1,000 chars, use case first, triggers
  sharpest-first — the listing truncates tails and the budget is shared
  (see the description rules in the authoring doc).
- **Tool skills carry a `**Pinned:**` line** and document commands that actually run on that
  version. `/skill-update` owns pin bumps; claims you didn't execute don't ship.
- **Agents preload only always-on skills** (`skills:` frontmatter), never tool-gated ones;
  least-privilege `tools:`; output goes to the caller, not the user.
- **Register everything** in CLAUDE.md (and the README tree) — `check-scaffold.sh` enforces this.

## The PR checklist

1. `bash .claude/scripts/check-scaffold.sh` passes (drift, frontmatter, config, install,
   ownership).
2. New/changed skill descriptions are within budget (the check above warns; the authoring doc
   has the numbers).
3. A `CHANGELOG.md` entry under an `Unreleased`/next-version heading, in the existing style.
4. If you changed policy-shaped content (`memory/policy/`, PROCESS.md), say why in the PR —
   those files are canon and get closer review.
5. One concern per PR. A new skill and a hook fix are two PRs.

## Design questions

Architecture decisions that keep coming up are recorded with their reasoning in
`.claude/memory/reference/` (start with `architecture-skills-vs-agents.md`) — read those before
proposing a restructure, and expect "revisit conditions" to be part of any counter-proposal.

## Reporting problems

Issues with a reproduction (the command you ran, what surfaced, what you expected) get fixed
fastest — especially skill-routing misses ("said X, expected skill Y to load"), since
descriptions are tuned from exactly that evidence.
