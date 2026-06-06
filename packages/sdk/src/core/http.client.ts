// ── Config ────────────────────────────────────────────────────
const BASE_URL =
    process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:4000";

// ── Auth token ────────────────────────────────────────────────
function getAuthToken(): string | null {
    if (typeof window === "undefined") return null;
    return localStorage.getItem("auth_token");
}

export function setAuthToken(token: string) {
    localStorage.setItem("auth_token", token);
}

export function clearAuthToken() {
    localStorage.removeItem("auth_token");
}

export function isAuthenticated(): boolean {
    return !!getAuthToken();
}

// ── Error class ───────────────────────────────────────────────
export class ApiError extends Error {
    constructor(
        public status: number,
        message: string,
        public body?: unknown,
    ) {
        super(message);
        this.name = "ApiError";
    }
}

// ── Core fetch wrapper ────────────────────────────────────────
// كل الـ requests بتمر من هنا:
// - بيضيف Content-Type تلقائياً
// - بيحول الـ errors لـ ApiError
// - بيرجع الـ JSON مع الـ type المطلوب

async function request<T>(
    path: string,
    options: RequestInit = {},
): Promise<T> {
    const url = `${BASE_URL}${path}`;

    const headers: Record<string, string> = {
        "Content-Type": "application/json",
    };

    const token = getAuthToken();
    if (token) {
        headers["Authorization"] = `Bearer ${token}`;
    }

    const res = await fetch(url, {
        ...options,
        headers: { ...headers, ...options.headers },
    });

    // حاول تقرأ الـ body دايماً حتى لو في error
    let body: unknown;
    try {
        body = await res.json();
    } catch {
        body = null;
    }

    if (!res.ok) {
        if (res.status === 401) {
            clearAuthToken();
            if (typeof window !== "undefined" && window.location.pathname !== "/login") {
                window.location.assign("/login");
            }
        }

        const message =
            (body as { error?: string })?.error ??
            `HTTP ${res.status}: ${res.statusText}`;
        throw new ApiError(res.status, message, body);
    }

    return body as T;
}

// ── Helper shortcuts ──────────────────────────────────────────
export function get<T>(path: string) {
    return request<T>(path, { method: "GET" });
}

export  function post<T>(path: string, data: unknown) {
    return request<T>(path, {
        method: "POST",
        body: JSON.stringify(data),
    });
}
    
export function put<T>(path: string, data: unknown) {
    return request<T>(path, {
        method: "PUT",
        body: JSON.stringify(data),
    });
}

export function patch<T>(path: string, data: unknown) {
    return request<T>(path, {
        method: "PATCH",
        body: JSON.stringify(data),
    });
}

export function del<T>(path: string) {
    return request<T>(path, { method: "DELETE" });
}
