---
name: governance
description: >
  The governance layer — how this repo's policy is organized and how to LOCATE, LOAD, APPLY, and RECORD
  against any policy file, for any governed domain. It's the index + access protocol over the policy canon
  in `.claude/memory/policy/`. Register one row per governed domain (e.g. CODE CONVENTIONS — the idioms
  every module follows; DATA / SCHEMA — the data model and its invariants; SECURITY — secrets, sensitive
  data, and egress). It points at the authored canon and never copies policy text (single source of
  truth). Run it directly whenever you touch a governed domain — each specialist consults it for the
  policy on what it edits; there is deliberately no governance-manager agent. Use it to: find which policy
  governs a change, load the right canon file, apply that domain's rules, record a judgment call, or add a
  new policy domain. Triggers: governance, policy, which policy applies, where/how to access the policy,
  apply a policy, is this allowed by policy, compliance, add a policy / new policy domain, decision log,
  ADR, record a decision — plus each domain's own sharp trigger words, folded in here as you add
  domains. For security (authored): secret, credential, API key, token, .env, PII, data egress,
  is this safe to log/send, leaked key, rotate a credential, threat model, prompt injection,
  supply chain, torch.load weights_only. <PLACEHOLDER: e.g. for code conventions — add/edit a
  module, error handling, logging, config, idioms; for data — data model, entity, field,
  migration, invariant>.
---

# Governance — the index + access protocol over this repo's policy

> On-demand: load this for any governed change — locating the right policy, applying it, recording a
> decision, or adding a policy domain. It's the map + protocol; the authored policy text lives in
> `.claude/memory/policy/` (below) and wins on any conflict. Run the loop directly whenever you touch a
> governed domain — no agent required.

## The governance model (two layers, one source of truth)
- **Canon** — the authored policy, a version-controlled file at `.claude/memory/policy/<domain>.md`. The
  source of truth. A human reads it; code is written and data is shaped from it.
- **This skill** — the index across domains + the access protocol + (folded-in) each domain's sharp
  triggers, so a governed change auto-surfaces governance and routes to the right canon. It never restates
  policy.

Policy text lives in exactly one place — the canon file — never copied into a skill or duplicated
elsewhere.

## Policy index (the domains + where their canon lives)
> Ships with the three domains below. Add a row per new governed domain (e.g. a `code-conventions.md`
> once your Python idioms stabilize); each row's canon file goes in `.claude/memory/policy/`.

| Domain | Governs | Canon (`.claude/memory/policy/`) | Decision log | Apply when… |
|---|---|---|---|---|
| `data-governance` | datasets, labels, licensing, PII/sensitive imagery, splits & leakage | `data-governance.md` | `data-governance-decision-log.md` | ingesting/splitting/labeling data, or adding a dataset |
| `model-governance` | trained-model reproducibility, checkpoint provenance, model cards, release + weight licensing | `model-governance.md` | `model-governance-decision-log.md` | training, checkpointing, or releasing a model |
| `security` | secrets & credentials, what may be logged/egressed, supply chain, the guardrails-vs-boundary threat model | `security.md` | `security-decision-log.md` | touching anything that holds or moves a credential, adding logging/tracking calls, or sending data anywhere external |
| `<code-conventions>` | how any source module is written — the repeated Python idioms | `<code-conventions.md>` | — | writing or editing any source file (add this canon when your idioms settle) |

_Add a row per new domain. If a domain produces a generated artifact (a spec the code implements), note
that it's data, not policy, and lives outside `policy/`. Decision logs are append-only and created on the
first judgment call — they won't exist until then._

## Access protocol — locate → load → apply → record
1. **Locate.** Match the change to a domain above (several can apply to one change). No matching domain
   ⇒ no policy yet; proceed or propose one.
2. **Load.** Read that domain's **canon** file in `.claude/memory/policy/`. Canon wins on conflict.
3. **Apply.** Follow the canon — copy the idioms, run the decision procedure, or check the invariants +
   checklist for that domain.
4. **Record.** If the domain has a **decision log**, log every irreducible judgment call there
   (append-only: what / which rule / why). Prescriptive domains (a fixed style guide) have no log.

## Add a policy domain (the extension protocol)
1. **Author the canon** at `.claude/memory/policy/<name>.md` — the authored source of truth.
2. **Register a row** in the Policy index above, and fold that domain's sharp triggers into this skill's
   `description` so governed changes auto-surface it.
3. If the domain makes judgment calls over time, add a **decision log** beside its canon.

Keep policy in ONE skill — this one; don't spawn a skill per policy domain. One index, many canon files.

## Who runs this
Any session or specialist that touches a governed domain runs the locate→load→apply→record loop directly —
the decentralized model: each specialist agent gets a one-line pointer to this skill for the policy on what
it edits. There is deliberately **no governance-manager agent** (policy is applied where the work happens,
not by a coordinator).

## Gotcha
This skill only **indexes and explains access** — it is deliberately thin. If you find yourself restating
idioms, rules, or checklists here, stop: that belongs in the canon file (single source of truth). Policy
canon lives in `.claude/memory/policy/`; this skill points at it and never copies it.
