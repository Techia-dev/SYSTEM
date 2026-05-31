// ============================================================
// Query Keys — مركزية لكل مفاتيح الـ cache
// بتُستخدم مع React Query (TanStack Query) أو SWR
// بتضمن إن الـ invalidation بيحصل صح
// ============================================================

export const queryKeys = {
    // ── Candidates ──────────────────────────────────────────
    candidates: {
        /** كل المرشحين */
        all: ["candidates"] as const,
    },

    // ── Offers ──────────────────────────────────────────────
    offers: {
        /** كل العروض */
        all: ["offers"] as const,
        /** عرض واحد بالـ ID */
        byId: (id: string) => ["offers", id] as const,
    },

    // ── Applications ────────────────────────────────────────
    applications: {
        /** كل الطلبات */
        all: ["applications"] as const,
        /** طلب واحد بالـ ID */
        byId: (id: string) => ["applications", id] as const,
    },

    // ── Commissions ─────────────────────────────────────────
    commissions: {
        /** كل العمولات */
        all: ["commissions"] as const,
        /** عمولة واحدة بالـ ID */
        byId: (id: string) => ["commissions", id] as const,
    },
} as const;