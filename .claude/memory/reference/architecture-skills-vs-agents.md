# Architecture: why skills stay in-context and there is no orchestrator agent

The recurring design question — "should every request carry every skill, or should specialist
agents hold their own skills and pass tasks through a manager?" — decided once, with the
reasoning recorded so it doesn't get re-litigated. (Same decision as "no governance-manager
agent" and "no project-manager agent", generalized.)

## The premise to correct first
"Every request includes every skill" is not what happens. A skill is two parts with different
costs: the **description** (~250 tokens) is always in context — it's the routing table; the
**body** (~1.5–2k tokens) loads only when the skill triggers. A session carries a ~4–5k-token
*router*, not a 50k-token library. Gating (tool/lane `skillOverrides`) prunes the router
per-project: a CV project never lists `tabular`.

## What a manager/orchestrator architecture would cost
Every delegation to a subagent pays, per hop:
- **Re-serialized context.** Subagents cannot see the conversation — everything relevant must be
  restated in the delegation prompt. This is the quality killer: DS work is iterative and
  conversational, and the surrounding context (what was just tried, what the user said about the
  data) is most of the signal.
- **The agent's fixed overhead** — system prompt + preloaded skill bodies + CLAUDE.md — usually
  *more* tokens than the router costs, paid again on every hop.
- **The user cut out of the loop.** Subagents can't ask the user anything. Gates, scope calls,
  "is this distribution weird or expected?" — all bounce back to the main session anyway.
- Latency per hop.

The router-in-context model pays ~5k once per session; the delegation model pays more than that
per handoff and loses context at each one.

## Where subagents DO win (and how this repo uses them)
Context **isolation**, not context savings, is the real product:
- Read-heavy investigation that would flood the main window → `Explore` / `general-purpose`.
- Separable build chunks → `data-engineer` / `ml-engineer`, with their load-bearing always-on
  skills **preloaded** via `skills:` frontmatter (subagents have no Skill tool).
- Fresh-eyes verification → `code-reviewer` (bias isolation: the reviewer didn't write it).
- Parallel fan-out over file-disjoint tasks → `wave-planning` manifest.
- Research pollution → `/skill-update` delegates bulk changelog reading.

## The standing division of labor
**Skills = knowledge, lazily loaded. Main session = the orchestrator, with the user in the
loop. Agents = context isolation for separable chunks.** The main session is already the
manager; adding another one adds a lossy hop, not leverage.

## Pressure valves, in order (when the router grows too big)
1. Gate more skills (tool/lane `skillOverrides` off) — free for anyone not in that lane.
2. `skillListingBudgetFraction` in `settings.json` (set to 0.02 here) — buy explicit headroom
   instead of letting the default ~1% budget silently drop least-used descriptions.
3. `"name-only"` in `skillOverrides` for rarely-triggered skills — listed, but description-free.
4. Tighten descriptions (the authoring budget rules) — the pass that cut 31% once can run again.
5. Only after all four: revisit this decision. The trigger that would actually justify
   agent-held skills is a roster so large that even a pruned router crowds real work — not
   aesthetic discomfort with a long listing.

Run `/doctor` to see the listing's actual measured cost at any time.
