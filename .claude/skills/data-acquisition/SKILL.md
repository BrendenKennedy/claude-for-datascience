---
name: data-acquisition
description: >
  Pulling data from APIs and the web — P2's ingest mechanics. Carries: cache-first design
  (persist every raw response verbatim before parsing; nothing is fetched twice), rate-limit
  budget math written before pulling (calls needed vs quota vs deadline), retry with exponential
  backoff + jitter honoring Retry-After, pagination and incremental sync (cursor / updated-since,
  not full re-pulls), provenance stamping on every record (source, fetched_at, source_version),
  schema validation at the boundary (APIs change silently), scraping legality + etiquette (ToS
  and robots.txt checked per source — a governance call), and credentials in `.env`, never in
  code. Load when wiring an API client, scraper, or any ingest job. Triggers: API, ingest, fetch
  data, scraper, scraping, rate limit, backoff, retry, requests, cache responses, pagination,
  cursor, pull data from, robots.txt, ToS, API key, quota.
---

# data-acquisition — ingest that survives contact with real APIs

> On-demand: load this before writing an API client or scraper. The *plan* lives in PROCESS.md
> P2 (source inventory T2, rate-limit math in the gate); this is how the code meets that plan.
> Licensing/ToS verdicts route to `governance` → `data-governance`; keys live in `.env`
> (`security` canon). Storage/provenance land in the P3 layout (`datasets` manifest).

## Cache first — the raw layer is sacred
Persist every response **verbatim** (raw JSON/HTML + status + headers + fetch timestamp) into an
immutable raw store, keyed by request, *before* any parsing. Parsing is a separate, re-runnable
step over the cache. Payoffs: a parser bug costs a re-parse, not a re-pull against quota; the
raw layer is the provenance record; and "nothing is fetched twice" falls out of a cache-hit
check. This is P3's raw-immutability rule applied at the wire.

## The budget math (before the first call, in writing)
`records needed ÷ records per call = calls needed` vs `quota per day` vs `days to deadline` —
plus a retry allowance (~10–20%). If the math doesn't close, the *plan* changes (narrower pull,
higher tier, different source) — discovering this on day 6 of 7 is the failure P2's gate exists
to prevent. Log the math in the source inventory (T2).

## Politeness + robustness (one client shape)
- **Retries:** exponential backoff **with jitter** on 429/5xx/timeouts; honor `Retry-After` when
  sent; cap attempts and record permanent failures — don't retry 4xx logic errors.
- **Pace proactively** to the documented limit (a token bucket / sleep between calls) instead of
  surfing 429s; concurrent workers share one budget.
- **Pagination:** follow the API's cursor to exhaustion, persist the cursor with the batch —
  page-number loops against changing data skip/duplicate records.
- **Incremental sync** after the first backfill: `updated_since` / cursor watermark per source,
  stored with the data — full re-pulls burn quota and hide upstream deletions.
- **Idempotent writes:** keyed on source record id + version, so a re-run upserts instead of
  duplicating.

## Trust nothing at the boundary
Validate incoming payloads against an explicit schema (pydantic or a column contract) at parse
time — APIs add/rename/repurpose fields without notice, and a silent schema drift becomes a
silent feature corruption three steps later. Stamp every parsed record with `source`,
`fetched_at`, `source_version` (P3's provenance columns). Schema changes bump `source_version`
and get a line in the data-quality notes.

## Scraping (when there's no API)
ToS + `robots.txt` checked and **noted per source** in T2 — a redistribution-hostile ToS is a
`data-governance` decision *before* engineering effort. Then: identify honestly (UA string),
respect crawl-delay, throttle harder than you think, cache aggressively (never re-scrape a page
you have), and expect breakage — parsers over scraped HTML get the same boundary validation as
APIs, with louder alerts.
