import type { LoginDto, LoginResponse, MeResponse, LogoutResponse } from "@techia/types";

const BASE_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:4000";

export function getAuthToken(): string | null {
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

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
    const url = `${BASE_URL}${path}`;
    const headers: Record<string, string> = { "Content-Type": "application/json" };

    const token = getAuthToken();
    if (token) headers["Authorization"] = `Bearer ${token}`;

    const res = await fetch(url, { ...options, headers: { ...headers, ...options.headers } });

    let body: unknown;
    try { body = await res.json(); } catch { body = null; }

    if (!res.ok) {
        const message = (body as { error?: string })?.error ?? `HTTP ${res.status}: ${res.statusText}`;
        if (res.status === 401) {
            clearAuthToken();
            if (typeof window !== "undefined" && window.location.pathname !== "/login") {
                window.location.assign("/login");
            }
        }
        throw new Error(message);
    }

    return body as T;
}

function post<T>(path: string, data: unknown) {
    return request<T>(path, { method: "POST", body: JSON.stringify(data) });
}

function get<T>(path: string) {
    return request<T>(path, { method: "GET" });
}

export const authApi = {
    login(data: LoginDto): Promise<LoginResponse> {
        return post("/api/auth/login", data);
    },
    me(): Promise<MeResponse> {
        return get("/api/auth/me");
    },
    logout(): Promise<LogoutResponse> {
        return post("/api/auth/logout", {});
    },
};
