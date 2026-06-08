export type ClientConfig = {
    baseURL: string;
    timeout?: number;
    headers?: Record<string, string>;
    apiPrefix?: string;
};

export type ApiResponse<T> = {
    success: true;
    data: T;
    meta?: Record<string, unknown>;
} | {
    success: false;
    error: {
        message: string;
        code: string;
        fields?: Record<string, string[]>;
    };
};

export class TechiaSdkError extends Error {
    constructor(
        public statusCode: number,
        public code: string,
        message: string,
        public fields?: Record<string, string[]>
    ) {
        super(message);
        this.name = "TechiaSdkError";
    }
}

export class HttpClient {
    private baseURL: string;
    private timeout: number;
    private headers: Record<string, string>;
    private apiPrefix: string;

    constructor(config: ClientConfig) {
        this.baseURL = config.baseURL;
        this.timeout = config.timeout ?? 30000;
        this.apiPrefix = config.apiPrefix ?? "/api";
        this.headers = {
            "Content-Type": "application/json",
            ...config.headers,
        };
    }

    setAuthToken(token: string): void {
        this.headers["Authorization"] = `Bearer ${token}`;
    }

    clearAuthToken(): void {
        delete this.headers["Authorization"];
    }

    async get<T>(path: string): Promise<T> {
        return this.request<T>(path, { method: "GET" });
    }

    async post<T>(path: string, data?: unknown, init?: RequestInit): Promise<T> {
        const isFormData = data instanceof FormData;
        return this.request<T>(path, {
            method: "POST",
            body: isFormData ? data : data ? JSON.stringify(data) : undefined,
            ...init,
        });
    }

    async put<T>(path: string, data?: unknown): Promise<T> {
        return this.request<T>(path, {
            method: "PUT",
            body: data ? JSON.stringify(data) : undefined,
        });
    }

    async delete<T>(path: string): Promise<T> {
        return this.request<T>(path, { method: "DELETE" });
    }

    async patch<T>(path: string, data?: unknown): Promise<T> {
        return this.request<T>(path, {
            method: "PATCH",
            body: data ? JSON.stringify(data) : undefined,
        });
    }

    private getAuthToken(): string | null {
        if (typeof window === "undefined") return null;
        return localStorage.getItem("auth_token");
    }

    private async request<T>(path: string, options: RequestInit): Promise<T> {
        const token = this.getAuthToken();
        const requestHeaders: Record<string, string> = {};

        if (token) {
            requestHeaders["Authorization"] = `Bearer ${token}`;
        }

        const isFormData = options.body instanceof FormData;
        const hasBody = options.body != null;
        if (!isFormData && hasBody) {
            Object.assign(requestHeaders, this.headers);
        }

        const url = `${this.baseURL}${this.apiPrefix}${path}`;
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), this.timeout);

        try {
            const response = await fetch(url, {
                ...options,
                headers: requestHeaders,
                signal: controller.signal,
            });

            const data: ApiResponse<T> = await response.json();

            if (!response.ok) {
                if (data.success === false) {
                    throw new TechiaSdkError(
                        response.status,
                        data.error.code,
                        data.error.message,
                        data.error.fields
                    );
                }
                throw new TechiaSdkError(
                    response.status,
                    "HTTP_ERROR",
                    `HTTP ${response.status}`
                );
            }

            if (data.success === true) {
                return data.data;
            }

            throw new TechiaSdkError(
                200,
                "INVALID_RESPONSE",
                "Received error response with 200 status"
            );
        } finally {
            clearTimeout(timeoutId);
        }
    }
}
