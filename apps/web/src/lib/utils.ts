// ============================================================
// API utilities — helper functions للاستخدام في الـ components
// ============================================================

import { TechiaSdkError } from "@techia/sdk";

export function getErrorMessage(err: unknown): string {
    if (err instanceof TechiaSdkError) {
        return err.message;
    }
    if (err instanceof Error) {
        return err.message;
    }
    return "An unexpected error occurred. Please try again.";
}

export function isNotFound(err: unknown): boolean {
    return err instanceof TechiaSdkError && err.statusCode === 404;
}

export function isConflict(err: unknown): boolean {
    return err instanceof TechiaSdkError && err.statusCode === 409;
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