// ============================================================
// Techia ATS — API Client
// يتكلم مع apps/api على PORT 4000 بشكل افتراضي
// كل الـ types مأخودة من @techia/types عشان type-safety كاملة
// ============================================================

import type {
    Candidate,
    CreateCandidateDto,
    CreateCandidateResponse,
    Offer,
    OfferWithCount,
    CreateOfferDto,
    UpdateOfferDto,
    CreateOfferResponse,
    Application,
    ApplicationWithRelations,
    ApplicationFull,
    CreateApplicationDto,
    UpdateApplicationStatusDto,
    CreateApplicationResponse,
    UpdateStatusResponse,
    Commission,
    CommissionWithRelations,
    UpdateCommissionStatusDto,
    UpdateCommissionResponse,
} from "@techia/types";

// ── Config ────────────────────────────────────────────────────
const BASE_URL =
    process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:4000";

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

    const res = await fetch(url, {
        ...options,
        headers: {
            "Content-Type": "application/json",
            ...options.headers,
        },
    });

    // حاول تقرأ الـ body دايماً حتى لو في error
    let body: unknown;
    try {
        body = await res.json();
    } catch {
        body = null;
    }

    if (!res.ok) {
        const message =
            (body as { error?: string })?.error ??
            `HTTP ${res.status}: ${res.statusText}`;
        throw new ApiError(res.status, message, body);
    }

    return body as T;
}

// ── Helper shortcuts ──────────────────────────────────────────
function get<T>(path: string) {
    return request<T>(path, { method: "GET" });
}

function post<T>(path: string, data: unknown) {
    return request<T>(path, {
        method: "POST",
        body: JSON.stringify(data),
    });
}

function put<T>(path: string, data: unknown) {
    return request<T>(path, {
        method: "PUT",
        body: JSON.stringify(data),
    });
}

function patch<T>(path: string, data: unknown) {
    return request<T>(path, {
        method: "PATCH",
        body: JSON.stringify(data),
    });
}

function del<T>(path: string) {
    return request<T>(path, { method: "DELETE" });
}

// ============================================================
// CANDIDATES  →  /api/candidates
// ============================================================

export const candidatesApi = {
    /** GET /api/candidates — كل المرشحين مرتبين بالأحدث */
    list(): Promise<Candidate[]> {
        return get("/api/candidates");
    },

    /** POST /api/candidates — إنشاء مرشح جديد */
    create(data: CreateCandidateDto): Promise<CreateCandidateResponse> {
        return post("/api/candidates", data);
    },
};

// ============================================================
// OFFERS  →  /api/offers
// ============================================================

export const offersApi = {
    /** GET /api/offers — كل العروض */
    list(): Promise<Offer[]> {
        return get("/api/offers");
    },

    /** GET /api/offers/:id — عرض واحد + عدد الطلبات */
    getById(id: string): Promise<OfferWithCount> {
        return get(`/api/offers/${id}`);
    },

    /** POST /api/offers — إنشاء عرض جديد */
    create(data: CreateOfferDto): Promise<CreateOfferResponse> {
        return post("/api/offers", data);
    },

    /** PUT /api/offers/:id — تعديل عرض */
    update(id: string, data: UpdateOfferDto): Promise<Offer> {
        return put(`/api/offers/${id}`, data);
    },

    /** DELETE /api/offers/:id — soft delete (isActive = false) */
    deactivate(id: string): Promise<{ message: string }> {
        return del(`/api/offers/${id}`);
    },
};

// ============================================================
// APPLICATIONS  →  /api/applications
// ============================================================

export const applicationsApi = {
    /** GET /api/applications — كل الطلبات مع الـ candidate + offer */
    list(): Promise<ApplicationWithRelations[]> {
        return get("/api/applications");
    },

    /** GET /api/applications/:id — طلب واحد مع كل التفاصيل والـ commission */
    getById(id: string): Promise<ApplicationFull> {
        return get(`/api/applications/${id}`);
    },

    /** POST /api/applications — إنشاء طلب جديد */
    create(data: CreateApplicationDto): Promise<CreateApplicationResponse> {
        return post("/api/applications", data);
    },

    /**
     * PUT /api/applications/:id/status — تغيير حالة الطلب
     * لو status = "accepted" → الـ backend بيعمل commission تلقائياً
     */
    updateStatus(
        id: string,
        data: UpdateApplicationStatusDto,
    ): Promise<UpdateStatusResponse> {
        return put(`/api/applications/${id}/status`, data);
    },
};

// ============================================================
// COMMISSIONS  →  /api/commissions
// ============================================================

export const commissionsApi = {
    /** GET /api/commissions — كل العمولات مع الـ candidate + offer */
    list(): Promise<CommissionWithRelations[]> {
        return get("/api/commissions");
    },

    /** GET /api/commissions/:id — عمولة واحدة مع كل التفاصيل */
    getById(
        id: string,
    ): Promise<Commission & { candidate: Candidate; offer: Offer }> {
        return get(`/api/commissions/${id}`);
    },

    /** PATCH /api/commissions/:id/status — تغيير حالة العمولة (pending → paid) */
    updateStatus(
        id: string,
        data: UpdateCommissionStatusDto,
    ): Promise<UpdateCommissionResponse> {
        return patch(`/api/commissions/${id}/status`, data);
    },
};

// ============================================================
// HEALTH CHECK  →  /health
// ============================================================

export const healthApi = {
    /** GET /health — للتأكد من أن الـ server شغال */
    check(): Promise<{ status: string; env: string; timestamp: string }> {
        return get("/health");
    },
};

// ── Named export كـ namespace واحد (اختياري) ─────────────────
export const api = {
    candidates: candidatesApi,
    offers: offersApi,
    applications: applicationsApi,
    commissions: commissionsApi,
    health: healthApi,
} as const;

export default api;