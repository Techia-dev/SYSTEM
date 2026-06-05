/**
 * Techia SDK - HTTP Client
 * Base HTTP client with automatic error handling and response parsing
 */

export type ClientConfig = {
    baseURL: string;
    timeout?: number;
    headers?: Record<string, string>;
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

    constructor(config: ClientConfig) {
        this.baseURL = config.baseURL;
        this.timeout = config.timeout ?? 30000;
        this.headers = {
            "Content-Type": "application/json",
            ...config.headers,
        };
    }

    /**
     * Set authorization header
     */
    setAuthToken(token: string): void {
        this.headers["Authorization"] = `Bearer ${token}`;
    }

    /**
     * Clear authorization header
     */
    clearAuthToken(): void {
        delete this.headers["Authorization"];
    }

    /**
     * Make a GET request
     */
    async get<T>(path: string): Promise<T> {
        return this.request<T>(path, { method: "GET" });
    }

    /**
     * Make a POST request
     */
    async post<T>(path: string, data?: unknown): Promise<T> {
        return this.request<T>(path, {
            method: "POST",
            body: data ? JSON.stringify(data) : undefined,
        });
    }

    /**
     * Make a PUT request
     */
    async put<T>(path: string, data?: unknown): Promise<T> {
        return this.request<T>(path, {
            method: "PUT",
            body: data ? JSON.stringify(data) : undefined,
        });
    }

    /**
     * Make a DELETE request
     */
    async delete<T>(path: string): Promise<T> {
        return this.request<T>(path, { method: "DELETE" });
    }

    /**
     * Core request method with error handling
     */
    private async request<T>(path: string, options: RequestInit): Promise<T> {
        const url = `${this.baseURL}${path}`;
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), this.timeout);

        try {
            const response = await fetch(url, {
                ...options,
                headers: this.headers,
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
