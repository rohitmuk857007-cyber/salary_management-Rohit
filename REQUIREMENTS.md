# Requirements — ACME Employee Salary Management

## Overview
HR Manager tool for managing ~10,000 employees across multiple countries: profiles, salary history, insights, CSV import/export.

## Personas
- **HR Manager**: authenticate, manage employees, set salaries, view payroll stats, import/export CSV.

## Functional Requirements

### Authentication
- Login with email/password
- Session-based auth (cookie) with CORS credentials for SPA
- Logout and current-user endpoint
- Default role: `hr`

### Employees
- CRUD employees
- Fields: employee_code (unique), first_name, last_name, email, country (ISO), department, hire_date, status (active/inactive)
- List filters: `q` (name/code/email), country, department, status
- Pagination: `page`, `per_page`

### Salaries
- Nested under employee (or sibling resource)
- Fields: amount_cents (integer), currency (ISO 4217), effective_from, effective_to (nullable), reason
- Current salary = row with `effective_to` nil (or latest open)
- Never overwrite: creating a new salary closes the prior open row (`effective_to` set)

### Stats
- `GET /api/v1/stats/overview`: headcount, total current payroll, by_country, by_department, salary_bands

### Import / Export
- `POST /api/v1/imports/employees` — CSV upload
- `GET /api/v1/exports/employees.csv` — CSV download

## Non-Functional
- Local demo with SQLite; Postgres documented for production
- Seed ~10k employees for scale demo
- Fast tests (small fixtures, no 10k seed in test)
- CORS allow `http://localhost:5173`

## Out of Scope (v1)
- Multi-tenant orgs, SSO, RBAC beyond single HR role
- Payroll processing / tax / benefits
- Real-time sync, audit log UI, mobile apps
