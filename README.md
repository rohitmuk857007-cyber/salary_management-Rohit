# ACME Employee Salary Management

Assessment-style HR app for managing ~10k employees across countries: profiles, salary history, insights, and CSV import/export.

## Stack

| Layer | Tech |
|-------|------|
| Backend | Rails 8 API-only (`backend/`), SQLite for local demo |
| Frontend | Vite + React + TypeScript (`frontend/`), plain CSS |
| Auth | Session cookie + `rack-cors` (`credentials: true`) |

**Production DB:** use PostgreSQL (swap `database.yml` / `DATABASE_URL`). Schema is portable; SQLite is for zero-ops local demos only.

## Quick start

### Backend

```bash
cd backend
bundle config set --local path 'vendor/bundle'
bundle install
bin/rails db:prepare
# Full demo (~10k employees). For a quick smoke: SEED_COUNT=100 bin/rails db:seed
bin/rails db:seed
bin/rails server -p 3000
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

Open http://localhost:5173

Optional: `VITE_API_URL=http://localhost:3000/api/v1` (default).

### Demo credentials

- Email: `hr@acme.com`
- Password: `password123`

## Tests

```bash
cd backend
bundle exec rails test
```

Tests use small fixtures only (never the 10k seed).

## API (JSON `/api/v1`)

- `POST /auth/login`, `DELETE /auth/logout`, `GET /auth/me`
- CRUD `/employees` — filters: `q`, `country`, `department`, `status`, `page`, `per_page`
- `/employees/:id/salaries` — list / create (create closes prior open salary)
- `GET /stats/overview`
- `POST /imports/employees` (multipart `file`), `GET /exports/employees.csv`

CORS allows `http://localhost:5173` with credentials.

## Project layout

```
REQUIREMENTS.md   ARCHITECTURE.md   TRADEOFFS.md   AI_PROMPTS.md
backend/          frontend/
```

## What was left out

- Multi-role RBAC / SSO / MFA
- FX-normalized global payroll (stats band by raw amount per currency)
- Full audit log UI, notifications, mobile clients
- Docker / Kamal / CI pipelines (Rails generators skipped for a lean demo)
- JWT (session cookies chosen instead)
- Soft-delete, bulk salary updates UI, employee create form in UI (API supports create)

## GitHub

Remote is unset by default. To publish:

```bash
git remote add origin git@github.com:<you>/salary_management-Rohit.git
git push -u origin main
```

Do not commit `backend/vendor/bundle`, SQLite files, or `frontend/node_modules` (see `.gitignore`).
