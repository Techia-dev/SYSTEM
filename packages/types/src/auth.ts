// ── API Requests ──────────────────────────────────────────
export interface LoginDto {
    email: string;
    password: string;
}

// ── API Responses ─────────────────────────────────────────
export interface LoginResponse {
    token: string;
    user: UserProfile;
}

export interface UserProfile {
    id: string;
    email: string;
    name: string | null;
    role: string;
}

export interface MeResponse {
    user: UserProfile;
}

export interface LogoutResponse {
    message: string;
}
