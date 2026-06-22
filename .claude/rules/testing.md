# Testing & verification

> Replace with this project's real verification story. The goal: tell the agent the cheapest way to
> gain confidence a change works, in increasing order of cost.

## Quick checks (in order of cost)
1. **Compiles / imports** (no side effects): `<command>`
2. **Unit tests** (fast, offline): `<command>`
3. **Integration / smoke test** (may need services up): `<command>`
4. **Run it for real** (interactive / end-to-end): `<command>`

## Preconditions
- <any service/endpoint/env that must be available for which tests; how to check it's up>
- Keep tests **offline-safe where possible**; gate live-dependency tests behind an availability check.

## Conventions
- <where tests live, naming pattern, how to run a single test>
- <when a change requires a new test vs. when a smoke check is enough>
