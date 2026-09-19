import { useEffect, useState, type FormEvent } from "react";
import { Link, useParams } from "react-router-dom";
import { api, formatMoney, type Employee, type Salary } from "../api/client";

const CURRENCIES: Record<string, string> = {
  US: "USD",
  IN: "INR",
  GB: "GBP",
  DE: "EUR",
  SG: "SGD",
  AU: "AUD",
};

export default function EmployeeDetail() {
  const { id } = useParams();
  const [employee, setEmployee] = useState<Employee | null>(null);
  const [error, setError] = useState("");
  const [amount, setAmount] = useState("");
  const [currency, setCurrency] = useState("USD");
  const [effectiveFrom, setEffectiveFrom] = useState(new Date().toISOString().slice(0, 10));
  const [reason, setReason] = useState("Adjustment");
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState("");

  async function load() {
    if (!id) return;
    try {
      const e = await api.employee(id);
      setEmployee(e);
      setCurrency(CURRENCIES[e.country] || e.current_salary?.currency || "USD");
      setError("");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load");
    }
  }

  useEffect(() => {
    load();
  }, [id]);

  async function onAddSalary(e: FormEvent) {
    e.preventDefault();
    if (!id) return;
    setBusy(true);
    setMsg("");
    try {
      const major = parseFloat(amount);
      if (!Number.isFinite(major) || major <= 0) throw new Error("Enter a positive amount");
      await api.createSalary(id, {
        amount_cents: Math.round(major * 100),
        currency,
        effective_from: effectiveFrom,
        reason,
      });
      setMsg("Salary updated. Prior open salary was closed.");
      setAmount("");
      await load();
    } catch (err) {
      setMsg(err instanceof Error ? err.message : "Failed to save salary");
    } finally {
      setBusy(false);
    }
  }

  if (error) return <div className="alert">{error}</div>;
  if (!employee) return <p className="muted">Loading…</p>;

  const salaries: Salary[] = employee.salaries || [];

  return (
    <div>
      <p>
        <Link to="/employees">← Employees</Link>
      </p>
      <div className="page-header">
        <div>
          <h1>{employee.full_name}</h1>
          <p className="muted">
            {employee.employee_code} · {employee.email}
          </p>
        </div>
        <span className={`badge ${employee.status}`}>{employee.status}</span>
      </div>

      <div className="grid-2">
        <div className="card">
          <h2>Profile</h2>
          <dl className="kv">
            <dt>Country</dt>
            <dd>{employee.country}</dd>
            <dt>Department</dt>
            <dd>{employee.department}</dd>
            <dt>Hire date</dt>
            <dd>{employee.hire_date}</dd>
            <dt>Current salary</dt>
            <dd>
              {employee.current_salary
                ? formatMoney(employee.current_salary.amount_cents, employee.current_salary.currency)
                : "—"}
            </dd>
          </dl>
        </div>

        <div className="card">
          <h2>Add / update salary</h2>
          <p className="muted small">Creates a new row and closes any open salary. History is never overwritten.</p>
          <form className="stack" onSubmit={onAddSalary}>
            <label>
              Amount (major units)
              <input value={amount} onChange={(e) => setAmount(e.target.value)} type="number" step="0.01" min="0" required />
            </label>
            <label>
              Currency
              <select value={currency} onChange={(e) => setCurrency(e.target.value)}>
                {Object.values(CURRENCIES).map((c) => (
                  <option key={c} value={c}>
                    {c}
                  </option>
                ))}
              </select>
            </label>
            <label>
              Effective from
              <input type="date" value={effectiveFrom} onChange={(e) => setEffectiveFrom(e.target.value)} required />
            </label>
            <label>
              Reason
              <input value={reason} onChange={(e) => setReason(e.target.value)} />
            </label>
            <button className="btn primary" type="submit" disabled={busy}>
              {busy ? "Saving…" : "Save salary"}
            </button>
            {msg && <p className="hint">{msg}</p>}
          </form>
        </div>
      </div>

      <div className="card table-wrap" style={{ marginTop: "1rem" }}>
        <h2>Salary timeline</h2>
        <table>
          <thead>
            <tr>
              <th>From</th>
              <th>To</th>
              <th>Amount</th>
              <th>Reason</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {salaries.map((s) => (
              <tr key={s.id}>
                <td>{s.effective_from}</td>
                <td>{s.effective_to || "—"}</td>
                <td>{formatMoney(s.amount_cents, s.currency)}</td>
                <td>{s.reason || "—"}</td>
                <td>{s.current || !s.effective_to ? <span className="badge active">current</span> : null}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
