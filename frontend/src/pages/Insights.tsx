import { useEffect, useState } from "react";
import { api, formatMoney, type StatsOverview } from "../api/client";

export default function Insights() {
  const [stats, setStats] = useState<StatsOverview | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    api
      .stats()
      .then(setStats)
      .catch((e) => setError(e.message || "Failed to load stats"));
  }, []);

  if (error) return <div className="alert">{error}</div>;
  if (!stats) return <p className="muted">Loading insights…</p>;

  const maxCountry = Math.max(1, ...Object.values(stats.by_country));
  const maxDept = Math.max(1, ...Object.values(stats.by_department));
  const maxBand = Math.max(1, ...Object.values(stats.salary_bands));

  return (
    <div>
      <div className="page-header">
        <h1>Insights</h1>
      </div>

      <div className="cards">
        <div className="stat-card card">
          <div className="stat-label">Active headcount</div>
          <div className="stat-value">{stats.headcount.toLocaleString()}</div>
        </div>
        {Object.entries(stats.total_payroll).map(([cur, cents]) => (
          <div className="stat-card card" key={cur}>
            <div className="stat-label">Payroll ({cur})</div>
            <div className="stat-value">{formatMoney(cents, cur)}</div>
          </div>
        ))}
      </div>

      <div className="grid-2" style={{ marginTop: "1rem" }}>
        <div className="card">
          <h2>By country</h2>
          <ul className="bars">
            {Object.entries(stats.by_country)
              .sort((a, b) => b[1] - a[1])
              .map(([k, v]) => (
                <li key={k}>
                  <span>{k}</span>
                  <div className="bar">
                    <div style={{ width: `${(v / maxCountry) * 100}%` }} />
                  </div>
                  <span>{v}</span>
                </li>
              ))}
          </ul>
        </div>
        <div className="card">
          <h2>By department</h2>
          <ul className="bars">
            {Object.entries(stats.by_department)
              .sort((a, b) => b[1] - a[1])
              .map(([k, v]) => (
                <li key={k}>
                  <span>{k}</span>
                  <div className="bar">
                    <div style={{ width: `${(v / maxDept) * 100}%` }} />
                  </div>
                  <span>{v}</span>
                </li>
              ))}
          </ul>
        </div>
      </div>

      <div className="card" style={{ marginTop: "1rem" }}>
        <h2>Salary bands (major units, mixed currencies)</h2>
        <p className="muted small">Demo banding on raw amounts — not FX-normalized.</p>
        <ul className="bars">
          {Object.entries(stats.salary_bands).map(([k, v]) => (
            <li key={k}>
              <span>{k.replace(/_/g, " ")}</span>
              <div className="bar">
                <div style={{ width: `${(v / maxBand) * 100}%` }} />
              </div>
              <span>{v}</span>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
