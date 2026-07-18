# PROCESS.md — A Hybrid Data Science Project Framework

> **Version:** 0.2.0 · **Last updated:** 2026-07-18 · **Owner:** _(you)_
> **Status:** Living document. Edited after every project retrospective (see Part V).

This is a reusable operating system for running data science projects — solo or as a lead. It is a deliberate cross-breed of the proven, published frameworks below, keeping what each does best and discarding what each underemphasizes. Every phase ends in an **exit gate**: questions you must answer in writing before moving on. Gates are the difference between a process and winging it.

**How to use it:** copy this file into the root of every new project repo. Fill the templates in Part IV as you go. Treat unfilled gates as blockers, not suggestions. In this repo, gates are not left to discipline — the `/gate` command walks the current phase's checklist and records the verdict (see §3.8). After shipping, run the retro and edit this document itself.

---

## Part I — Lineage: the proven frameworks underneath

Nothing here is invented from scratch. Each element is traceable to a published methodology with decades of industry use. Knowing the names matters — they are interview vocabulary, searchable anchors, and evidence that the process rests on more than one person's habits.

### Source frameworks at a glance

| Framework | Origin | Core contribution | What we adopt | What we leave |
|---|---|---|---|---|
| **KDD** | Fayyad, Piatetsky-Shapiro & Smyth, 1996 (academic) | First formalization: mining is one step inside a larger discovery process; iteration is inherent | The iterative, non-linear mindset | Academic framing; no business or delivery phases |
| **SEMMA** | SAS, mid-1990s | Disciplined technical loop: Sample → Explore → Modify → Model → Assess | EDA rigor before modeling | Tool-centric; skips business understanding and deployment entirely |
| **CRISP-DM** | Industry consortium (SPSS, Daimler, NCR, OHRA), 1999–2000 | The 6-phase backbone: Business Understanding → Data Understanding → Data Preparation → Modeling → Evaluation → Deployment, with explicit back-loops | Phase structure; business-first ordering; iteration arrows | Vague on teams, tooling, QA, and anything after deployment |
| **TDSP** | Microsoft, 2016 | Team operability: defined roles, standardized repo structure, document templates, agile cadence | Roles, standardized repo layout, named documentation artifacts | Fixed-length sprints (poor fit for research uncertainty); Azure tool coupling |
| **CRISP-ML(Q)** | Studer et al., 2021 (arXiv 2003.05155) | Quality assurance loop (identify risk → mitigate) attached to *every* task, plus a dedicated Monitoring & Maintenance phase | Per-phase risk/QA discipline; the monitoring phase; measurable success criteria incl. a non-ML baseline | Heavyweight formality where a solo project needs speed |
| **Agile DS (Scrum/Kanban adaptations)** | Practitioner community, 2010s | Time-boxing, visible backlog, demo cadence | Kanban-style hypothesis backlog; regular demos | Sprint *commitments* for research tasks — experiments don't estimate well |
| **MLOps** | Google ("MLOps levels 0–2"), Sculley et al. "Hidden Technical Debt in ML Systems" (2015) | Reproducibility, versioning of data/models/code, drift monitoring, automation maturity levels | Pinned environments, seeds, data snapshots, experiment tracking, monitoring concepts | Full CI/CD automation — overkill until something is actually deployed |
| **Cookiecutter Data Science** | DrivenData | Standardized repo layout; "notebooks explore, `src/` productionizes" | Directory conventions and the exploration/production split | Nothing — it's small and composable |
| **Lean / hypothesis-driven development** | Lean Startup lineage; Google's "Rules of ML" | Falsifiable hypotheses, kill criteria, simplest-thing-first, baseline-before-model | Kill criteria in Phase 1; baseline-first rule in Phase 5 | Growth-hacking framing irrelevant to modeling work |
| **Data-centric AI / annotation ops** | Practitioner community (label-quality research, e.g. Northcutt et al. on label errors; standard IAA statistics) | Labels are a manufactured artifact with a measurable defect rate, not ground truth by decree | Annotation spec, pilot + inter-annotator agreement, gold sets, label-error audits (P2) | Vendor/platform specifics |

### Why CRISP-DM is the spine

CRISP-DM remains the most widely used data science process framework decades after publication — practitioner polls consistently place it far ahead of alternatives. It earned that position by being industry-agnostic, business-first, and honest about iteration. Its known weaknesses are exactly what the other frameworks patch:

- **No team model** → patched by TDSP (roles, artifacts, repo standards)
- **No QA methodology** → patched by CRISP-ML(Q) (risk identification per task)
- **Nothing after deployment** → patched by CRISP-ML(Q) Phase 6 + MLOps monitoring
- **No reproducibility discipline** → patched by MLOps practices
- **No explicit stopping rule** → patched by Lean kill criteria
- **No labeling discipline** → patched by data-centric AI / annotation-ops practice (no classical framework covers it)

### Design principles of the hybrid

1. **Gates over vibes.** Every phase has written exit criteria. A phase is done when its gate passes, not when it feels done.
2. **Baselines before models.** No trained model is meaningful until compared against the dumbest credible alternative.
3. **Provenance everywhere.** Every data value, decision, and experiment must be traceable to a source, a date, and a rationale.
4. **Scope is a written contract.** v1 is defined in writing; everything else lives in a parking lot and must pass a gate to enter scope.
5. **Leakage is the default failure mode.** Temporal validity is checked explicitly, per feature, in writing.
6. **The process is itself versioned.** This document has a version number and a changelog because it is expected to change.
7. **Label quality is measured, not assumed.** Any label this project *produces* (rather than inherits) gets a written spec, a pilot with inter-annotator agreement, and an audited error rate before a model trains on it.
8. **Gates are enforced by structure, not discipline.** The gate is a checklist file that a tool refuses to pass while items are unchecked (§3.8) — not a habit you promise to keep. A process that depends on remembering to follow it is the failure mode this document exists to prevent.

---

## Part II — The Lifecycle

```
┌────────────┐   ┌────────────┐   ┌──────────────┐   ┌─────────────┐   ┌──────────────┐   ┌──────────────┐
│ P1 Problem │ → │ P2 Data    │ → │ P3 Data      │ → │ P4 Feature  │ → │ P5 Modeling  │ → │ P6 Delivery  │
│ Definition │   │ Discovery  │   │ Architecture │   │ Engineering │   │ & Evaluation │   │ & Retro      │
└────────────┘   └────────────┘   └──────────────┘   └─────────────┘   └──────────────┘   └──────────────┘
      ↑________________↑_________________↑___________________↑_________________│                  │
                        (iteration loops back at any point — CRISP-DM style)                      ▼
                                                                                    ┌─────────────────────────┐
                                                                                    │ P7 Monitoring &         │
                                                                                    │ Maintenance (if deployed)│
                                                                                    └─────────────────────────┘
```

Iteration is expected: evaluation results routinely send you back to features or data. What is *not* allowed is skipping a gate on the way forward.

---

### P1 — Problem Definition
**Provenance:** CRISP-DM Business Understanding · CRISP-ML(Q) success criteria & feasibility · Lean kill criteria

**Purpose:** Lock the target, the consumer, the metric, and the stopping rule before any code exists.

**Key activities**
- Write the one-page problem statement: prediction target, who consumes the output, what decision it informs
- Define constraints: deadline, data access, compute, budget
- Define **measurable** success criteria: metric + threshold + the baseline it must beat
- Name a **non-ML heuristic benchmark** (CRISP-ML(Q) practice) — the simplest rule a human could apply
- Write **kill criteria**: the result that means stop or pivot
- Feasibility sanity check: does the data plausibly exist to answer this?
- **Compute feasibility math:** estimate the cost of one training run (GPU-hours) and the number of runs the plan implies; check the product against the hardware you actually have and the deadline. Order-of-magnitude is fine here — the estimate hardens into a tracked budget in P5. This is the same move as P2's rate-limit math, applied to GPUs: for deep-learning work, compute arithmetic kills projects just as dead as API quotas.

**Outputs:** Problem statement (Template T1) · success metric definition · kill criteria · rough compute budget

**In this repo:** `/intake` opens with exactly this interview (step 0) — archetype + lane fit, T1, and an anti-pattern challenge pass — and writes `.claude/memory/process/project-definition.md`, which doubles as most of this gate's evidence.

**Exit gate**
- [ ] A stranger could read the problem statement and state exactly what "done" means
- [ ] The success metric is computable from data you can actually obtain
- [ ] A baseline is named in writing
- [ ] Kill criteria are written
- [ ] Deadline and constraints are explicit
- [ ] Compute math done: est. GPU-hours per training run × planned runs fits the available hardware and the deadline

---

### P2 — Data Discovery
**Provenance:** CRISP-DM Data Understanding · TDSP Data Acquisition & Understanding · (labeling: data-centric AI practice — no classical framework covers annotation ops)

**Purpose:** Verify — not assume — that every planned feature has an obtainable, legal, fresh-enough source, and that any labels the project must *produce* can be produced at a measured, acceptable quality.

**Key activities**
- Build the source inventory (Template T2): endpoint, auth, rate limits, licensing/ToS, update cadence
- Pull *sample* data from every source before committing to it
- Data quality audit: missingness, ranges, duplicates, encoding traps, weird distributions
- Design the acquisition plan: caching strategy, retry/backoff, rate-limit budget math
- Log discovered risks into the risk register

**Labeling & annotation** *(conditional — applies when this project produces labels rather than inherits them; skip and mark N/A otherwise)*
- Write the **annotation spec** (Template T8) *before* anyone labels: class definitions, boundary rules (occlusion, truncation, crowding, ambiguous cases), canonical positive/negative/hard examples, and what explicitly does **not** get labeled
- **Pilot round:** label a small batch with ≥2 annotators (solo: you, twice, a week apart), measure **inter-annotator agreement** (Cohen's κ for class labels; IoU-based agreement for boxes/masks), and revise the spec + re-pilot until agreement clears a threshold you wrote down first
- Build a **gold set** — a re-reviewed, trusted subset — for auditing annotator drift during production labeling
- **Audit delivered labels:** sample, re-review, and record the label error rate. An unmeasured label error rate becomes an invisible ceiling on every model trained downstream

**Outputs:** Source inventory · data quality notes · ingest plan with caching policy · (if labeling) annotation spec + IAA result + label error rate

**Exit gate**
- [ ] Every feature in the plan maps to a verified source (sample actually pulled)
- [ ] ToS / licensing checked and noted per source
- [ ] Rate-limit math done: total calls needed vs. daily budget vs. deadline
- [ ] Caching policy defined (raw responses persisted; nothing fetched twice)
- [ ] Quality risks logged in the risk register
- [ ] *(if labeling)* Annotation spec written and survived a pilot: IAA measured and above the written threshold
- [ ] *(if labeling)* Label error rate estimated from an audited sample and small relative to the margin the success metric needs
- [ ] *(if labeling)* Gold set exists, if labeling continues past this phase

---

### P3 — Data Architecture
**Provenance:** TDSP standardized structure · MLOps versioning & provenance · Cookiecutter Data Science layout

**Purpose:** Make the data layer boring, traceable, and query-friendly before feature work begins.

**Key activities**
- Design the schema (entities, keys, relationships, indexes) around the *queries feature engineering will run*
- Choose storage with a migration path (e.g., SQLite → PostgreSQL via SQLAlchemy)
- Define versioning: snapshot reference data on every upstream version change (e.g., game patch, API schema rev)
- Add provenance columns as standard: `source`, `collected_at`, `source_version`
- Scaffold the repo (see layout below); raw data is **immutable** — transforms write new tables, never overwrite source
- Environment pinned from day one (`pyproject.toml` / lockfile)

**Standard repo layout** *(generic default — **in this repo** the layout is generated by `/bootstrap`
(Hydra `conf/` tree + `train.py`/`eval.py`); defer to it and keep only this section's invariants:
immutable raw data, provenance columns, pinned env)*
```
project/
├── data/          # raw cache, gitignored, immutable
├── db/            # database file(s), gitignored
├── src/
│   ├── ingest/    # API clients, scrapers, parsers
│   ├── schema/    # ORM models / DDL
│   ├── features/  # feature computation
│   └── models/    # training + evaluation
├── notebooks/     # exploration only — logic graduates to src/
├── tests/
├── PROCESS.md     # this file
└── README.md
```

**Outputs:** Schema doc/DDL · repo scaffold · versioning policy

**Exit gate**
- [ ] Any value in the database can be traced to source + collection date + source version
- [ ] Raw data immutability rule is enforced by structure, not discipline
- [ ] Schema supports the aggregate queries Phase 4 will need (tested with one real query)
- [ ] Environment is pinned and reproducible

---

### P4 — Feature Engineering
**Provenance:** CRISP-ML(Q) per-task QA · hypothesis-driven development · MLOps testing discipline

**Purpose:** Turn raw data into signals, with a written reason and a leakage check for every one.

> **For vision / deep-learning projects:** read "feature" as *any input-representation choice* — crop geometry, resolution, augmentation policy, channel selection, label definition. The discipline is identical: each choice gets a written hypothesis and a leakage/temporal-validity review. (An augmentation or normalization computed from whole-dataset statistics is leakage too — normalization stats come from train only.)

**Key activities**
- Maintain the feature dictionary (Template T5): every feature gets a **hypothesis** — the causal story for why it should carry signal
- **Leakage review per feature:** was this information available at prediction time? Historical aggregates must be computed only from data *before* each training example
- Unit-test feature computations (known input → known output)
- Distribution sanity checks after computation (ranges, nulls, cardinality)
- Aggregations are *computed* in the feature layer, not stored as facts — schema holds truth, features hold signal

**Outputs:** Feature dictionary · tested feature pipeline

**Exit gate**
- [ ] Every feature has a written hypothesis
- [ ] Every feature passed an explicit leakage / temporal-validity review
- [ ] Feature computations have passing unit tests
- [ ] Distributions eyeballed and anomalies explained or fixed

---

### P5 — Modeling & Evaluation
**Provenance:** CRISP-DM Modeling + Evaluation · Google "Rules of ML" (start simple) · MLOps experiment tracking

**Purpose:** Beat a defensible baseline on the Phase-1 metric, and know *where* and *why* the model fails.

**Key activities**
- **Baselines first, always:** majority class → simple interpretable model (logistic regression) → domain baseline (e.g., market-implied probabilities). No complex model until these exist
- **Experiment budget:** before the first non-baseline model, harden P1's rough compute estimate into a written plan — the experiments you intend to run, est. GPU-hours each, against the total you have before the deadline. Every experiment gets a written question and a time/compute budget *before* it starts (§3.6); track spend as you go
- Temporal train/test split when data has time structure — random splits leak the future
- Log every run in the experiment log (Template T6): date, data snapshot, features, params, metrics
- Calibrate if probabilities are consumed downstream (log loss / Brier score, `CalibratedClassifierCV`) — an accurate-but-overconfident model is worse than useless when compared against odds
- Error analysis: segment the failures. *Where* it fails matters more than how often
- Robustness spot-checks: does performance survive across time slices / subgroups?

**Outputs:** Experiment log · experiment budget with tracked spend · evaluation report vs. baseline · model card-lite (intended use, training data, metrics, known limits)

**Exit gate**
- [ ] Documented comparison against every baseline on the Phase-1 metric
- [ ] Split strategy is temporal (or leakage-safe) and stated in writing
- [ ] Error analysis written: top failure modes identified
- [ ] Calibration checked if probabilities are the product
- [ ] Experiment spend tracked against the written compute budget; overruns were decided in writing (decision log), not drifted into
- [ ] Kill criteria from P1 consulted: continue, pivot, or stop — decided explicitly

---

### P6 — Delivery & Retrospective
**Provenance:** TDSP Customer Acceptance · MLOps reproducibility · the meta-loop (Part V)

**Purpose:** Ship something a stranger — or you in six months — can rerun, then extract the process lessons.

**Key activities**
- Reproducibility pass: pinned env, fixed seeds, data snapshot or deterministic fetch script, one-command run
- README: problem, results, how to reproduce, limitations
- Deliver: demo, report, video walkthrough, or deployment — whatever Phase 1 said the consumer needed
- Run the retrospective (Template T7)
- **Edit this PROCESS.md** based on the retro; bump the version

**Outputs:** Reproducible repo · README · retro doc · updated PROCESS.md

**Exit gate**
- [ ] Clean-environment rerun succeeds (or the gaps are honestly documented)
- [ ] README lets a stranger understand and reproduce the result
- [ ] Retro completed and PROCESS.md updated with at least one change (or a written "no changes needed")

---

### P7 — Monitoring & Maintenance *(conditional: deployed systems only)*
**Provenance:** CRISP-ML(Q) Phase 6 · MLOps drift monitoring

**Purpose:** A model in a changing environment degrades by default; this phase makes degradation visible and actionable.

**Key activities**
- Monitor live performance on the Phase-1 metric
- Detect input drift (feature distributions) and concept drift (relationship changes — e.g., a balance patch changes the game)
- Define retraining triggers: schedule-based, drift-based, or upstream-event-based (new patch ⇒ retrain)
- Name an owner and an alerting path

**Exit gate**
- [ ] Staleness criteria written (what measurement means "the model is stale")
- [ ] Retraining trigger defined and tested once
- [ ] An owner is named

---

## Part III — The PM Layer (cross-cutting)

These artifacts run through every phase. They are not paperwork *about* the management — they **are** the management. A lead's job is largely keeping these current and enforcing the gates other people want to skip.

### 3.1 Decision Log
One line per decision: date, decision, alternatives considered, rationale. Leads get asked "why did we do X?" constantly; this is the answer. It also stops re-litigating settled questions. Log anything you'd have to reconstruct from memory later (storage choice, scope cuts, source selection, metric choice).

**In this repo:** process-level decisions (scope, metric, kill/pivot, gate judgment calls) land in `.claude/memory/process/decision-log.md`, via the `governance` skill's record protocol. Domain-specific calls (data licensing, model release, security) go in that domain's log under `.claude/memory/policy/` — one home per decision, no parallel logs.

### 3.2 Risk Register
Top 3–7 live risks, each with likelihood, impact, and a mitigation. Reviewed at every phase gate. New risks discovered mid-phase get logged immediately, not remembered later. (This is CRISP-ML(Q)'s core QA move — identify risk, mitigate risk — generalized to the whole project.)

### 3.3 Scope Ledger
Two lists: **v1 (the contract)** and **the parking lot**. Anything not in v1 goes to the parking lot by default. Promotion from parking lot to scope requires a written gate: what does it add, what does it cost, what does it displace? This is how scope creep dies.

**In this repo:** the v1 contract lives in `.claude/memory/process/scope-ledger.md`; the parking lot **is** `.claude/memory/roadmap.md` — one backlog, not two. Promotions get a line in the decision log.

### 3.4 Experiment Log
Every model run: date, data snapshot ID, feature set, params, metrics, one-line takeaway. A spreadsheet is fine; MLflow is fine; a markdown table is fine. What is not fine is "I think the third run was the good one."

**In this repo:** the experiment log **is** the tracker (MLflow, via the `tracking-mlflow` skill — params, metrics, config snapshot, takeaway as a run note). T6 is the fallback for pre-tracking spikes only; two experiment logs is how one goes stale.

### 3.5 Feature Dictionary
Every feature: name, formula/source, hypothesis, leakage review result, added date. Doubles as documentation for the video/report and as the leakage audit trail.

### 3.6 Cadence
- **Solo mode:** a weekly self-review against the current phase gate + risk register. Timebox exploration: any experiment gets a written question and a time budget before it starts.
- **Team mode:** short standups; phase-gate reviews as scheduled checkpoints with stakeholders; demo at every phase exit. Prefer **Kanban with a hypothesis backlog** ("test whether X improves metric Y") over fixed sprint commitments — research tasks estimate poorly, which is the known friction point of forcing Scrum onto DS work.

### 3.7 Roles (team mode, adapted from TDSP)
- **Project lead** — owns the gates, the decision log, and stakeholder communication
- **Data scientist(s)** — own features, models, experiment log
- **Data engineer** — owns ingest, schema, pipeline reliability
- **Stakeholder / product owner** — signs off on the problem statement (P1 gate) and acceptance (P6 gate)

Solo projects: you hold all four hats — the framework's value is forcing you to *switch hats deliberately* instead of letting the data-scientist hat silently overrule the project-lead hat.

### 3.8 Gate Enforcement
Principle 8 made mechanical. "Treat unfilled gates as blockers" is exactly the kind of rule that survives only as long as motivation does — the same failure mode P3 refuses for data immutability ("enforced by structure, not discipline"). So gates get structure:

- **The gate is a file.** The current phase and every gate checklist live in a **phase-state file** in the repo, as literal checkboxes filled in writing — in this repo, `.claude/memory/process/phase-state.md`. "We passed P2" is a claim about that file, not a recollection.
- **Transitions happen only through a gate review.** A forward phase transition is performed by an explicit review that walks the checklist item by item, demanding *evidence* (a file, a number, a link) rather than assent — in this repo, the `/gate` command. It refuses to advance the phase while any non-N/A item is unchecked.
- **The risk register is reviewed at every gate review** (§3.2) — same mechanism, so it actually happens.
- **Unchecked items are gate debt.** They are recorded by name in the phase-state file, visible at the next session's start — not silently forgotten. Working *inside* a phase with open debt is fine; moving *forward* past it is not.
- **Conditional items** (e.g., the labeling items in P2, P7 entirely) may be marked **N/A with a written reason** — a reason, not a shrug.

---

## Part IV — Templates (copy-paste)

### T1 — Problem Statement (one page, Phase 1)
```
PROJECT: ____________________  DATE: ________  OWNER: ________
PREDICTION TARGET: What exactly is being predicted, at what moment in time?
CONSUMER & DECISION: Who uses the output, and what decision does it change?
CONSTRAINTS: Deadline / data access / compute / budget
SUCCESS METRIC: Metric + threshold + baseline it must beat
NON-ML BENCHMARK: The simplest heuristic a human could apply
KILL CRITERIA: The result that means stop or pivot
COMPUTE BUDGET: GPU-hours available before deadline · est. cost of one training run · runs the plan implies
FEASIBILITY NOTES: Why the data plausibly supports this
```

### T2 — Source Inventory (Phase 2, one row per source)
```
| Source | What it provides | Access/auth | Rate limits | License/ToS | Update cadence | Verified (date) |
|--------|------------------|-------------|-------------|-------------|----------------|-----------------|
```

### T3 — Decision Log
```
| Date | Decision | Alternatives considered | Rationale |
|------|----------|-------------------------|-----------|
```

### T4 — Risk Register
```
| # | Risk | Likelihood | Impact | Mitigation | Status |
|---|------|-----------|--------|------------|--------|
```

### T5 — Feature Dictionary (one row per feature)
```
| Feature | Definition / formula | Source tables | Hypothesis (why signal?) | Leakage review | Added |
|---------|---------------------|---------------|--------------------------|----------------|-------|
```

### T6 — Experiment Log
```
| Date | Data snapshot | Feature set | Model + params | Metric(s) | Takeaway |
|------|--------------|-------------|----------------|-----------|----------|
```

### T7 — Retrospective (Phase 6)
```
WHAT THE PROCESS CAUGHT: gates that saved us from something
WHAT THE PROCESS MISSED: problems no gate covered
WASTED MOTION: work that a better process would have prevented
GATE EDITS: specific changes to PROCESS.md (add/modify/remove a gate or template)
CARRY-FORWARD: parking-lot items promoted to the next project
VERSION BUMP: old → new, one-line changelog entry
```

### T8 — Annotation Spec (Phase 2, when this project produces labels)
```
TASK: What is being labeled (classes / boxes / masks / …), on what data
CLASSES: One-line definition per class — sharp enough that two strangers agree
BOUNDARY RULES: Rulings for occlusion, truncation, crowding, and each known ambiguous case
DO NOT LABEL: Explicit exclusions
EXAMPLES: Links to canonical positive / negative / hard examples
IAA PILOT: Batch size · annotators · agreement metric (κ / IoU-agreement) · threshold (written BEFORE measuring) · measured value + date
LABEL AUDIT: Sample size · label error rate · date · verdict (acceptable vs. the success-metric margin?)
GOLD SET: Where it lives · size · how drift is checked against it
```

### Scope Ledger
```
V1 (CONTRACT):
- ...

PARKING LOT (requires written promotion gate):
- ...
```

---

## Part V — The Meta-Loop

The artifact of any single project is disposable. The asset is the process that produced it. So the process must improve on the same cadence as the projects:

1. Ship (P6 gate passes)
2. Retro (T7)
3. **Edit this document** — add, sharpen, or delete gates based on what actually happened
4. Bump the version, one-line changelog entry below
5. Next project starts from the improved version

Run this loop across three or four projects and the result is a personal methodology with provenance — which is precisely the artifact that distinguishes a lead from a senior IC. In interviews, this document *is* the answer to "how do you run a project?"

### Changelog
```
0.2.0 (2026-07-18) — Gap fixes: labeling & annotation discipline (P2 conditional activities +
                     gate items, template T8, principle 7, data-centric AI lineage row);
                     compute budgeting (P1 feasibility math + gate + T1 line, P5 experiment
                     budget + gate); gate enforcement made mechanical (§3.8, principle 8 —
                     phase-state file + /gate review); CV reading of "feature" noted in P4.
0.1.0 (2026-07-18) — Initial synthesis: CRISP-DM spine + TDSP team layer +
                     CRISP-ML(Q) QA/monitoring + MLOps reproducibility +
                     Lean kill criteria + Cookiecutter layout.
```

---

## Appendix A — Worked example: Dota 2 pre-match outcome predictor (v1)

A partial fill to show intended use.

**T1 Problem Statement (abridged)**
- **Target:** P(Radiant win) at draft completion, pre-match, professional matches
- **Consumer/decision:** self — compare model probability vs. bookmaker implied probability; flag positive-EV divergences
- **Constraints:** ~2 weeks to TI; OpenDota free tier (rate-limited); solo
- **Success metric:** log loss & Brier score vs. bookmaker implied probabilities (calibration matters more than accuracy)
- **Non-ML benchmark:** always predict the side with higher aggregate hero win rate this patch
- **Kill criteria:** if v1 cannot beat the naive benchmark on a temporal holdout, stop feature-stacking and re-examine the data before adding model complexity

**Risk register (top entries)**
| # | Risk | Mitigation |
|---|------|------------|
| 1 | Balance patch drops before TI, invalidating hero-mechanics features | Key hero data on `hero_id + patch`; snapshot dotaconstants per patch; retrain on patch boundary |
| 2 | API rate limits vs. deadline | Cache every raw response to disk; budget calls/day in the ingest plan |
| 3 | Feature leakage via historical aggregates | Per-feature temporal review (P4 gate); temporal train/test split |

**Scope ledger**
- **v1:** hero composition + mechanics features only, pre-match
- **Parking lot:** player-hero performance, playstyle features, live in-match models (15/30/45 min), ensemble weighting, odds-scraper automation

---

## Appendix B — References & further reading

- CRISP-DM 1.0: Chapman et al., *CRISP-DM Step-by-Step Data Mining Guide* (2000)
- Fayyad, Piatetsky-Shapiro, Smyth — *From Data Mining to Knowledge Discovery in Databases*, AI Magazine (1996) — the KDD process
- Microsoft — *Team Data Science Process* documentation (Microsoft Learn, Azure Architecture Center) and the Azure/Microsoft-TDSP GitHub repo
- Studer et al. — *Towards CRISP-ML(Q): A Machine Learning Process Model with Quality Assurance Methodology* (arXiv:2003.05155; MDPI MAKE, 2021); practitioner summary at ml-ops.org
- Sculley et al. — *Hidden Technical Debt in Machine Learning Systems* (NeurIPS 2015)
- Northcutt, Athalye, Mueller — *Pervasive Label Errors in Test Sets Destabilize Machine Learning Benchmarks* (NeurIPS 2021) — why label error rates get measured
- Google — *MLOps: Continuous delivery and automation pipelines in machine learning* (maturity levels 0–2); *Rules of ML*
- DrivenData — *Cookiecutter Data Science* (repo layout convention)
- datascience-pm.com — framework adoption surveys and framework summaries (CRISP-DM, TDSP, SEMMA comparisons)
