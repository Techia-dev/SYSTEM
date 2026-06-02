// ============================================================
// API utilities — helper functions للاستخدام في الـ components
// ============================================================

import { ApiError } from "./api";

// ── getErrorMessage ───────────────────────────────────────────
// بتحول أي نوع من الـ errors لـ string مقروءة للـ UI

export function getErrorMessage(err: unknown): string {
    if (err instanceof ApiError) {
        return err.message;
    }
    if (err instanceof Error) {
        return err.message;
    }
    return "حدث خطأ غير متوقع. حاول مرة أخرى.";
}

// ── isNotFound ────────────────────────────────────────────────
// تشيك إذا كان الـ error 404

export function isNotFound(err: unknown): boolean {
    return err instanceof ApiError && err.status === 404;
}

// ── isConflict ────────────────────────────────────────────────
// تشيك إذا كان الـ error 409 (مثلاً email موجود بالفعل)

export function isConflict(err: unknown): boolean {
    return err instanceof ApiError && err.status === 409;
}

// ── formatCurrency ────────────────────────────────────────────
// تنسيق الأرقام كـ EGP

export function formatCurrency(amount: number): string {
    return new Intl.NumberFormat("ar-EG", {
        style: "currency",
        currency: "EGP",
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    }).format(amount);
}

// ── isDueOverdue ──────────────────────────────────────────────
// تشيك إذا كان الـ dueDate فات

export function isOverdue(dueDateString: string): boolean {
    return new Date(dueDateString) < new Date();
}