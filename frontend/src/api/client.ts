const API_BASE = import.meta.env.VITE_API_URL || "http://localhost:3000/api/v1";

export class ApiError extends Error {
  status: number;
  body: unknown;
  constructor(status: number, body: unknown) {
    super(typeof body === "object" && body && "error" in body ? String((body as { error: string }).error) : `HTTP ${status}`);
    this.status = status;
    this.body = body;
  }
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const headers = new Headers(options.headers || {});
  if (options.body && !(options.body instanceof FormData) && !headers.has("Content-Type")) {
    headers.set("Content-Type", "application/json");
  }
  headers.set("Accept", "application/json");

  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers,
    credentials: "include",
  });

  if (res.status === 204) return undefined as T;

  const text = await res.text();
  let body: unknown = null;
  if (text) {
    try {
      body = JSON.parse(text);
    } catch {
      body = text;
    }
  }

  if (!res.ok) throw new ApiError(res.status, body);
  return body as T;
}

export type User = { id: number; email: string; role: string };

export type Salary = {
  id: number;
  amount_cents: number;
  currency: string;
  effective_from: string;
  effective_to: string | null;
  reason: string | null;
  current?: boolean;
};

export type Employee = {
  id: number;
  employee_code: string;
  first_name: string;
  last_name: string;
  full_name: string;
  email: string;
  country: string;
  department: string;
  hire_date: string;
  status: string;
  current_salary?: {
    id: number;
    amount_cents: number;
    currency: string;
    effective_from: string;
    reason: string | null;
  } | null;
  salaries?: Salary[];
};

export type EmployeeList = {
  employees: Employee[];
  meta: { page: number; per_page: number; total: number; total_pages: number };
};

export type StatsOverview = {
  headcount: number;
  total_payroll: Record<string, number>;
  by_country: Record<string, number>;
  by_department: Record<string, number>;
  salary_bands: Record<string, number>;
};

export const api = {
  login: (email: string, password: string) =>
    request<{ user: User }>("/auth/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    }),
  logout: () => request<void>("/auth/logout", { method: "DELETE" }),
  me: () => request<{ user: User }>("/auth/me"),
  employees: (params: Record<string, string | number | undefined>) => {
    const q = new URLSearchParams();
    Object.entries(params).forEach(([k, v]) => {
      if (v !== undefined && v !== "") q.set(k, String(v));
    });
    return request<EmployeeList>(`/employees?${q}`);
  },
  employee: (id: number | string) => request<Employee>(`/employees/${id}`),
  createEmployee: (employee: Partial<Employee>) =>
    request<Employee>("/employees", { method: "POST", body: JSON.stringify({ employee }) }),
  updateEmployee: (id: number | string, employee: Partial<Employee>) =>
    request<Employee>(`/employees/${id}`, { method: "PATCH", body: JSON.stringify({ employee }) }),
  createSalary: (
    employeeId: number | string,
    salary: { amount_cents: number; currency: string; effective_from: string; reason?: string }
  ) =>
    request<Salary>(`/employees/${employeeId}/salaries`, {
      method: "POST",
      body: JSON.stringify({ salary }),
    }),
  stats: () => request<StatsOverview>("/stats/overview"),
  importEmployees: (file: File) => {
    const fd = new FormData();
    fd.append("file", file);
    return request<{ created: number; updated: number; errors: unknown[] }>("/imports/employees", {
      method: "POST",
      body: fd,
    });
  },
  exportUrl: () => `${API_BASE}/exports/employees.csv`,
};

export function formatMoney(cents: number, currency: string): string {
  try {
    return new Intl.NumberFormat(undefined, { style: "currency", currency }).format(cents / 100);
  } catch {
    return `${(cents / 100).toFixed(2)} ${currency}`;
  }
}
