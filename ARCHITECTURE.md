# Architecture

## Monorepo Layout
```
/
├── backend/          # Rails 7+/8 API-only, SQLite (dev/test)
├── frontend/         # Vite + React + TypeScript
├── REQUIREMENTS.md
├── ARCHITECTURE.md
├── TRADEOFFS.md
├── AI_PROMPTS.md
└── README.md
```

## Backend
- **Rails API-only** under `backend/`
- **SQLite** for local demo; production recommendation: PostgreSQL
- **Auth**: Rails session cookie + `rack-cors` with `credentials: true`
- **JSON API** versioned under `/api/v1`
- Models: `User`, `Employee`, `Salary`
- Salary history: append-only current row; service/model callback closes prior open salary

## Frontend
- Vite + React + TypeScript
- Pages: Login, Employees list, Employee detail, Insights, Import
- `fetch` with `credentials: 'include'` against `http://localhost:3000`
- Light CSS (no heavy UI kit)

## Data Flow
```
Browser (5173) --CORS+cookie--> Rails API (3000) --> SQLite
```

## Scaling Notes
- Seed uses `insert_all` in batches of 1000
- List endpoints paginated
- Stats computed via SQL aggregates on current salaries
