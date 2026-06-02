// ============================================================
// Badge — حالات الطلبات والعمولات والمرشحين
// ============================================================

import type { ApplicationStatus, CommissionStatus, CandidateLevel } from "@techia/types";

// ── Variant map ───────────────────────────────────────────────

const variants = {
    // application status
    applied: "bg-blue-50   text-blue-700   ring-blue-200",
    interview: "bg-amber-50  text-amber-700  ring-amber-200",
    accepted: "bg-emerald-50 text-emerald-700 ring-emerald-200",
    rejected: "bg-red-50    text-red-700    ring-red-200",
    // commission status
    pending: "bg-amber-50  text-amber-700  ring-amber-200",
    paid: "bg-emerald-50 text-emerald-700 ring-emerald-200",
    // candidate level
    junior: "bg-violet-50 text-violet-700 ring-violet-200",
    mid: "bg-blue-50   text-blue-700   ring-blue-200",
    senior: "bg-orange-50 text-orange-700 ring-orange-200",
    lead: "bg-rose-50   text-rose-700   ring-rose-200",
    // offer
    active: "bg-emerald-50 text-emerald-700 ring-emerald-200",
    inactive: "bg-zinc-100  text-zinc-500   ring-zinc-200",
} as const;

type BadgeVariant = keyof typeof variants;

// ── Dot color map ──────────────────────────────────────────────

const dotColors: Partial<Record<BadgeVariant, string>> = {
    applied: "bg-blue-500",
    interview: "bg-amber-500",
    accepted: "bg-emerald-500",
    rejected: "bg-red-500",
    pending: "bg-amber-500",
    paid: "bg-emerald-500",
};

// ── Component ─────────────────────────────────────────────────

interface BadgeProps {
    variant: BadgeVariant;
    /** إظهار نقطة ملونة قبل النص — مفيدة للـ status */
    dot?: boolean;
    children: React.ReactNode;
    className?: string;
}

export function Badge({ variant, dot = false, children, className = "" }: BadgeProps) {
    return (
        <span
            className={[
                "inline-flex items-center gap-1.5",
                "px-2 py-0.5 rounded-full text-xs font-medium",
                "ring-1 ring-inset",
                variants[variant],
                className,
            ].join(" ")}
        >
            {dot && dotColors[variant] && (
                <span
                    className={`w-1.5 h-1.5 rounded-full shrink-0 ${dotColors[variant]}`}
                    aria-hidden="true"
                />
            )}
            {children}
        </span>
    );
}

// ── Typed helpers (بيسهلوا الاستخدام) ─────────────────────────

export function ApplicationBadge({ status }: { status: ApplicationStatus }) {
    const labels: Record<ApplicationStatus, string> = {
        applied: "Applied",
        interview: "Interview",
        accepted: "Accepted",
        rejected: "Rejected",
    };
    return (
        <Badge variant={status as BadgeVariant} dot>
            {labels[status] ?? status}
        </Badge>
    );
}

export function CommissionBadge({ status }: { status: CommissionStatus }) {
    return (
        <Badge variant={status} dot>
            {status === "paid" ? "Paid" : "Pending"}
        </Badge>
    );
}

export function LevelBadge({ level }: { level: CandidateLevel }) {
    const labels: Record<CandidateLevel, string> = {
        junior: "Junior",
        mid: "Mid",
        senior: "Senior",
        lead: "Lead",
    };
    return <Badge variant={level}>{labels[level]}</Badge>;
}

export function OfferStatusBadge({ isActive }: { isActive: boolean }) {
    return (
        <Badge variant={isActive ? "active" : "inactive"} dot={isActive}>
            {isActive ? "Active" : "Inactive"}
        </Badge>
    );
}