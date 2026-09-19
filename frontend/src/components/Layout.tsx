import { Link, NavLink, Outlet, useNavigate } from "react-router-dom";
import { useAuth } from "../auth";

export default function Layout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  async function onLogout() {
    await logout();
    navigate("/login");
  }

  return (
    <div className="app">
      <header className="topbar">
        <Link to="/" className="brand">
          ACME Salary
        </Link>
        <nav>
          <NavLink to="/employees">Employees</NavLink>
          <NavLink to="/insights">Insights</NavLink>
          <NavLink to="/import">Import</NavLink>
        </nav>
        <div className="userbox">
          <span>{user?.email}</span>
          <button type="button" className="btn ghost" onClick={onLogout}>
            Log out
          </button>
        </div>
      </header>
      <main className="main">
        <Outlet />
      </main>
    </div>
  );
}
