import { useState, type FormEvent } from "react";
import { api } from "../api/client";

export default function ImportPage() {
  const [file, setFile] = useState<File | null>(null);
  const [result, setResult] = useState<{ created: number; updated: number; errors: unknown[] } | null>(null);
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    if (!file) {
      setError("Choose a CSV file");
      return;
    }
    setBusy(true);
    setError("");
    setResult(null);
    try {
      const r = await api.importEmployees(file);
      setResult(r);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Import failed");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div>
      <div className="page-header">
        <h1>Import employees</h1>
      </div>
      <div className="card" style={{ maxWidth: 560 }}>
        <p className="muted">
          CSV columns: employee_code, first_name, last_name, email, country, department, hire_date, status
          (optional: salary_amount_cents, currency, salary_effective_from, salary_reason).
        </p>
        <form className="stack" onSubmit={onSubmit}>
          <input type="file" accept=".csv,text/csv" onChange={(e) => setFile(e.target.files?.[0] || null)} />
          <button className="btn primary" type="submit" disabled={busy}>
            {busy ? "Uploading…" : "Upload CSV"}
          </button>
        </form>
        {error && <div className="alert">{error}</div>}
        {result && (
          <div className="hint">
            Created {result.created}, updated {result.updated}, errors {result.errors.length}
            {result.errors.length > 0 && (
              <pre className="errors-pre">{JSON.stringify(result.errors, null, 2)}</pre>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
