# AI prompts used

High-level prompts / instructions that shaped this repo (paraphrased for clarity):

1. **Scaffold monorepo** — Create an ACME salary management app under a local path with Rails API + Vite React TS, SQLite demo, Postgres noted for production, incremental git commits, and assessment docs (REQUIREMENTS, ARCHITECTURE, TRADEOFFS, AI_PROMPTS, README).

2. **Domain model** — Users with `has_secure_password`; employees with country/department/status; salaries as history rows with `amount_cents`, currency, effective dates; never overwrite — close prior open salary when assigning a new one.

3. **API surface** — Session-cookie auth with CORS credentials for localhost:5173; versioned `/api/v1` CRUD employees (filter + paginate), nested salaries, stats overview, CSV import/export.

4. **Seed at scale** — Seed HR demo user and 10k employees via `insert_all` batches without Faker; lightweight name generator; 1–3 salary rows each; `SEED_COUNT` for smoke runs.

5. **Frontend HR UX** — Login, employee list/filters, detail + salary timeline form, insights dashboard with simple CSS bars, CSV import page — clean and usable, not flashy.

6. **Tests** — Minitest covering salary close behavior, employee validations, stats with fixtures, login; keep fixtures small.

7. **Commit plan** — Seven meaningful commits from docs stubs through backend features, seed/tests, frontend, and final README polish.
