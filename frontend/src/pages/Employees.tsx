import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { api, formatMoney, type Employee } from "../api/client";

const COUNTRIES = ["", "US", "IN", "GB", "DE", "SG", "AU"];
const DEPARTMENTS = ["", "Engineering", "Sales", "HR", "Finance", "Operations", "Support"];
const STATUSES = ["", "active", "inactive"];

export default function Employees() {
  const [q, setQ] = useState("");
  const [country, setCountry] = useState("");
  const [department, setDepartment] = useState("");
  const [status, setStatus] = useState("active");
  const [page, setPage] = useState(1);
  const [rows, setRows] = useState<Employee[]>([]);
  const [meta, setMeta] = useState({ page: 1, per_page: 25, total: 0, total_pages: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    api
      .employees({ q, country, department, status, page, per_page: 25 })
      .then((data) => {
        if (cancelled) return;
        setRows(data.employees);
        setMeta(data.meta);
        setError("");
      })
      .catch((e) => !cancelled && setError(e.message || "Failed to load"))
      .finally(() => !cancelled && setLoading(false));
    return () => {
      cancelled = true;
    };
  }, [q, country, department, status, page]);

  return (
    <div>
      <div className="page-header">
        <h1>Employees</h1>
        <a className="btn ghost" href={api.exportUrl()} target="_blank" rel="noreferrer">
          Export CSV
        </a>
      </div>

      <div className="filters card">
        <input
          placeholder="Search name, code, email…"
          value={q}
          onChange={(e) => {
            setPage(1);
            setQ(e.target.value);
          }}
        />
        <select
          value={country}
          onChange={(e) => {
            setPage(1);
            setCountry(e.target.value);
          }}
        >
          {COUNTRIES.map((c) => (
            <option key={c || "all"} value={c}>
              {c || "All countries"}
            </option>
          ))}
        </select>
        <select
          value={department}
          onChange={(e) => {
            setPage(1);
            setDepartment(e.target.value);
          }}
        >
          {DEPARTMENTS.map((d) => (
            <option key={d || "all"} value={d}>
              {d || "All departments"}
            </option>
          ))}
        </select>
        <select
          value={status}
          onChange={(e) => {
            setPage(1);
            setStatus(e.target.value);
          }}
        >
          {STATUSES.map((s) => (
            <option key={s || "all"} value={s}>
              {s || "All statuses"}
            </option>
          ))}
        </select>
      </div>

      {error && <div className="alert">{error}</div>}

      <div className="card table-wrap">
        <table>
          <thead>
            <tr>
              <th>Code</th>
              <th>Name</th>
              <th>Country</th>
              <th>Department</th>
              <th>Status</th>
              <th>Current salary</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan={6} className="muted">
                  Loading…
                </td>
              </tr>
            ) : rows.length === 0 ? (
              <tr>
                <td colSpan={6} className="muted">
                  No employees found
                </td>
              </tr>
            ) : (
              rows.map((e) => (
                <tr key={e.id}>
                  <td>
                    <Link to={`/employees/${e.id}`}>{e.employee_code}</Link>
                  </td>
                  <td>
                    <Link to={`/employees/${e.id}`}>{e.full_name}</Link>
                    <div className="muted small">{e.email}</div>
                  </td>
                  <td>{e.country}</td>
                  <td>{e.department}</td>
                  <td>
                    <span className={`badge ${e.status}`}>{e.status}</span>
                  </td>
                  <td>
                    {e.current_salary
                      ? formatMoney(e.current_salary.amount_cents, e.current_salary.currency)
                      : "—"}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      <div className="pager">
        <button className="btn ghost" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>
          Previous
        </button>
        <span className="muted">
          Page {meta.page} of {meta.total_pages || 1} · {meta.total} total
        </span>
        <button
          className="btn ghost"
          disabled={page >= meta.total_pages}
          onClick={() => setPage((p) => p + 1)}
        >
          Next
        </button>
      </div>
    </div>
  );
}
