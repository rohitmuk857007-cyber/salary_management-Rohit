# Tradeoffs

## SQLite vs Postgres
- **Chose SQLite** for zero-ops local demo and assessment portability.
- **Cost**: limited concurrency; some SQL dialect differences.
- **Mitigation**: document Postgres for production; keep schema portable (no SQLite-only types beyond defaults).

## Session cookies vs JWT
- **Chose Rails session cookies** + CORS credentials: simpler logout, no token storage in SPA, CSRF mitigated with careful CORS origin allowlist.
- **Cost**: requires credentialed CORS and same-site considerations; harder for pure mobile clients.
- **Alternative**: JWT in Authorization header if multi-client later.

## Salary history model
- **Chose** immutable history with `effective_to` closure rather than overwriting.
- **Cost**: more rows; need careful transaction when adding salary.
- **Benefit**: audit-friendly timeline; clear “current” = `effective_to IS NULL`.

## No Faker gem
- **Chose** lightweight in-repo name/country generator for seeds.
- **Cost**: less realistic variety than Faker.
- **Benefit**: fewer install/native issues in constrained environments.

## Frontend deps
- Plain CSS (+ optional light charting) over full UI frameworks to keep install light and UI “HR-usable, not flashy.”

## Tests
- Small fixtures only; never load 10k in CI/tests for speed.
