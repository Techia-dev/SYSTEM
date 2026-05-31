// ============================================================
// Button — زرار موحد مع كل الـ variants
// ============================================================

import { type ButtonHTMLAttributes, forwardRef } from "react";

// ── Types ─────────────────────────────────────────────────────

type ButtonVariant = "primary" | "secondary" | "ghost" | "danger";
type ButtonSize = "sm" | "md" | "lg";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: ButtonVariant;
    size?: ButtonSize;
    loading?: boolean;
    icon?: React.ReactNode;
    iconPosition?: "left" | "right";
}

// ── Style maps ────────────────────────────────────────────────

const variantStyles: Record<ButtonVariant, string> = {
    primary:
        "bg-emerald-600 text-white hover:bg-emerald-700 active:bg-emerald-800 " +
        "focus-visible:ring-emerald-500 shadow-sm",
    secondary:
        "bg-white text-zinc-700 border border-zinc-200 " +
        "hover:bg-zinc-50 active:bg-zinc-100 " +
        "focus-visible:ring-zinc-300 shadow-sm",
    ghost:
        "text-zinc-600 hover:bg-zinc-100 active:bg-zinc-200 " +
        "focus-visible:ring-zinc-300",
    danger:
        "bg-red-600 text-white hover:bg-red-700 active:bg-red-800 " +
        "focus-visible:ring-red-500 shadow-sm",
};

const sizeStyles: Record<ButtonSize, string> = {
    sm: "h-7  px-2.5 text-xs  gap-1.5 rounded-md",
    md: "h-8  px-3   text-sm  gap-2   rounded-lg",
    lg: "h-10 px-4   text-sm  gap-2   rounded-lg",
};

// ── Component ─────────────────────────────────────────────────

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
    function Button(
        {
            variant = "secondary",
            size = "md",
            loading = false,
            icon,
            iconPosition = "left",
            disabled,
            children,
            className = "",
            ...props
        },
        ref,
    ) {
        const isDisabled = disabled || loading;

        return (
            <button
                ref={ref}
                disabled={isDisabled}
                className={[
                    "inline-flex items-center justify-center font-medium",
                    "transition-colors duration-150",
                    "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-1",
                    "disabled:opacity-50 disabled:cursor-not-allowed",
                    variantStyles[variant],
                    sizeStyles[size],
                    className,
                ].join(" ")}
                {...props}
            >
                {loading ? (
                    <Spinner size={size} />
                ) : (
                    iconPosition === "left" && icon && (
                        <span className="shrink-0" aria-hidden="true">{icon}</span>
                    )
                )}

                {children && <span>{children}</span>}

                {!loading && iconPosition === "right" && icon && (
                    <span className="shrink-0" aria-hidden="true">{icon}</span>
                )}
            </button>
        );
    },
);

// ── Spinner ───────────────────────────────────────────────────

function Spinner({ size }: { size: ButtonSize }) {
    const dim = size === "sm" ? "w-3 h-3" : "w-4 h-4";
    return (
        <svg
            className={`${dim} animate-spin`}
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            aria-hidden="true"
        >
            <circle
                className="opacity-25"
                cx="12" cy="12" r="10"
                stroke="currentColor" strokeWidth="4"
            />
            <path
                className="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
            />
        </svg>
    );
}