---
name: wrangling
description: >
  Pandas data manipulation without silent corruption. Carries: merge discipline (state the
  expected grain; `validate="many_to_one"` on every merge; row counts before/after; anti-join
  the unmatched), datetime/timezone hygiene (parse to tz-aware UTC at the boundary; never
  compare naive to aware), dtype management (categoricals + downcasting for memory; NaN silently
  forcing float; nullable dtypes), vectorize-don't-iterate (`iterrows` never in hot paths;
  `.apply` is a loop in disguise), chained-indexing traps (SettingWithCopy — `.loc`, copy
  deliberately), groupby `transform` vs `agg`, and reproducible ordering (sort before
  dedupe/head — row order is not a contract). Load when joining, reshaping, or cleaning
  dataframes. Triggers: pandas, dataframe, merge, join dataframes, concat, groupby, pivot, melt,
  reshape, datetime, timezone, dtype, SettingWithCopy, iterrows, apply, NaN, duplicates rows,
  dataframe memory.
---

# wrangling — dataframe surgery that doesn't lie

> On-demand: load this for non-trivial pandas work. What to *look for* is `eda`; modeling
> pipelines are `tabular`/`timeseries`; SQL-side work is `sql` (and pushing compute there beats
> heroic pandas). This skill is the manipulation layer's silent-failure catalog — pandas rarely
> errors; it returns a wrong dataframe with a straight face.

## Merges: state the grain, make pandas enforce it
Every merge has an intended cardinality — write it down and let pandas check it:
```python
out = left.merge(right, on="key", how="left", validate="many_to_one")  # raises on violation
```
- **Row counts before and after, asserted.** Unexplained growth = duplicate keys on the right =
  rows silently duplicated *and up-weighted in training*.
- **Anti-join the unmatched** (`indicator=True`, filter `left_only`) — unmatched rows are a
  filter you didn't mean to apply or a data-quality finding (→ P2 notes).
- Dedupe keys **deliberately**: `sort_values(...).drop_duplicates("key", keep="first")` — the
  sort makes "which row survives" a decision; without it, it's whatever order the file was in.

## Datetimes: UTC-aware at the boundary, once
Parse with an explicit format (`pd.to_datetime(s, format=..., utc=True)`) at ingest; convert to
local zones only for display. Naive-vs-aware comparisons raise when you're lucky and shift
silently when you're not (DST). Storage in UTC, `dt.tz_convert` for humans, and never
`dt.tz_localize` on data that's already UTC-in-disguise.

## Dtypes: memory and meaning
- `NaN` in an int column silently promotes to float (and `groupby` drops NaN groups by default —
  `dropna=False` when the missing group *is* a finding). Nullable dtypes (`Int64`, `boolean`)
  when missingness is real.
- High-repetition strings → `category`: order-of-magnitude memory wins and faster groupbys —
  but categories accumulate across concats/merges; re-check after joins.
- IDs are strings/categories, not ints — leading zeros and "the mean of customer_id" bugs.

## Vectorize; iterate only on purpose
`iterrows()` in a hot path is a 100–1000× tax; `.apply(axis=1)` is the same loop with better
PR. Prefer column arithmetic, `np.where`/`np.select`, `.map` for lookups, and groupby
**`transform`** (aligned back to rows — a per-group feature) vs **`agg`** (one row per group —
a summary); mixing those two up mis-shapes silently on the next merge.

## Assignment and order
- Chained indexing (`df[df.a > 0]["b"] = ...`) may edit a copy — the SettingWithCopy trap. One
  `.loc[mask, "b"] = ...` does what it says; slice-then-keep gets an explicit `.copy()`.
- **Row order is not a contract.** Anything order-sensitive (`head`, `drop_duplicates`, "first"
  aggregations, train/test by position) gets an explicit `sort_values` first — same
  reproducibility rule as everywhere else, at dataframe altitude.

## When pandas is the wrong tool
Bigger-than-memory or join-heavy work → push to `sql`/DuckDB (it reads parquet in place);
that's the escalation path, not chunked-pandas heroics.
