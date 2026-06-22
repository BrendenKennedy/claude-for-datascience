---
name: example-skill
description: >
  REPLACE THIS. A skill is auto-surfaced to Claude purely by this description, so it must say
  BOTH what knowledge the skill carries AND when to reach for it. Pack it with the concrete words
  and phrases the user will actually use, because matching happens on this text alone. Template:
  "<What this skill knows — the domain, the system, the contract>. Use for <the tasks it covers>.
  Triggers: <comma-separated phrases, tool names, file paths, jargon a user might type>."
---

# <Skill name> — <one-line subtitle>

> A **skill** is on-demand expertise: deep, ground-truth domain knowledge that Claude loads only
> when the `description` matches the task. Reach for it *before* acting in its domain — it carries
> the authoritative detail that the lightweight CLAUDE.md map intentionally omits.

## When this applies
<The situations where this skill is the source of truth. Mirrors the description's triggers.>

## The facts
<The actual knowledge: endpoints, versions, commands, gotchas, contracts, exact configs. This is
what makes a skill worth having — specifics an agent can't guess and shouldn't re-derive. Use
tables and code blocks freely.>

| Thing | Value |
|---|---|
| <key fact> | <value> |

## How to do X
```bash
# concrete, copy-pasteable commands
```

## Gotchas
- <the non-obvious failure mode and how to avoid it>

<!--
Authoring notes (delete in real skills):
- One skill = one coherent domain. If it sprawls, split it.
- The directory name and `name:` should match and be kebab-case: skills/<name>/SKILL.md.
- Skills can include supporting files alongside SKILL.md (scripts, reference docs); link to them
  with relative paths and Claude can read them on demand.
- Put deep knowledge WITH discovery triggers here. Reusable "how we do X" with no triggers →
  .claude/docs/reference/. What happened in a session → .claude/docs/sessions/.
- Keep it refined and current. A stale skill is worse than no skill.
-->
