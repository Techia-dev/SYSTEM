// ============================================================
// Modal — dialog قابل للوصول مع backdrop
// بيستخدم dialog element الـ native للـ accessibility
// ============================================================

"use client";

import { useEffect, useRef } from "react";
import { Button } from "./Button";

interface ModalProps {
    open: boolean;
    onClose: () => void;
    title: string;
    description?: string;
    children: React.ReactNode;
    /** عرض الـ modal — default: md */
    size?: "sm" | "md" | "lg";
}

const sizeMap = {
    sm: "max-w-sm",
    md: "max-w-md",
    lg: "max-w-lg",
};

export function Modal({
    open,
    onClose,
    title,
    description,
    children,
    size = "md",
}: ModalProps) {
    const dialogRef = useRef<HTMLDialogElement>(null);

    // مزامنة open state مع الـ dialog element
    useEffect(() => {
        const dialog = dialogRef.current;
        if (!dialog) return;
        if (open && !dialog.open) {
            dialog.showModal();
        } else if (!open && dialog.open) {
            dialog.close();
        }
    }, [open]);

    // إغلاق بـ Escape (الـ dialog بيدعمه native)
    useEffect(() => {
        const dialog = dialogRef.current;
        if (!dialog) return;
        const handler = () => onClose();
        dialog.addEventListener("close", handler);
        return () => dialog.removeEventListener("close", handler);
    }, [onClose]);

    // إغلاق بالنقر على الـ backdrop
    function handleBackdropClick(e: React.MouseEvent<HTMLDialogElement>) {
        if (e.target === dialogRef.current) onClose();
    }

    return (
        <dialog
            ref={dialogRef}
            onClick={handleBackdropClick}
            className={[
                "w-full rounded-xl shadow-xl p-0 bg-white",
                "backdrop:bg-black/40 backdrop:backdrop-blur-sm",
                "open:animate-in open:fade-in open:zoom-in-95",
                sizeMap[size],
            ].join(" ")}
            aria-labelledby="modal-title"
            aria-describedby={description ? "modal-description" : undefined}
        >
            {/* Header */}
            <div className="flex items-start justify-between px-5 pt-5 pb-3 border-b border-zinc-100">
                <div>
                    <h2 id="modal-title" className="text-base font-semibold text-zinc-900">
                        {title}
                    </h2>
                    {description && (
                        <p id="modal-description" className="mt-0.5 text-sm text-zinc-500">
                            {description}
                        </p>
                    )}
                </div>
                <button
                    onClick={onClose}
                    className="ml-4 p-1 rounded-md text-zinc-400 hover:text-zinc-600 hover:bg-zinc-100 transition-colors"
                    aria-label="Close modal"
                >
                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                        <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>

            {/* Body */}
            <div className="px-5 py-4">{children}</div>
        </dialog>
    );
}

// ── Modal Footer helper ───────────────────────────────────────

export function ModalFooter({
    onCancel,
    onConfirm,
    confirmLabel = "Confirm",
    confirmVariant = "primary",
    loading = false,
    cancelLabel = "Cancel",
}: {
    onCancel: () => void;
    onConfirm: () => void;
    confirmLabel?: string;
    confirmVariant?: "primary" | "danger";
    loading?: boolean;
    cancelLabel?: string;
}) {
    return (
        <div className="flex justify-end gap-2 pt-3 mt-2 border-t border-zinc-100">
            <Button variant="ghost" onClick={onCancel} disabled={loading}>
                {cancelLabel}
            </Button>
            <Button variant={confirmVariant} onClick={onConfirm} loading={loading}>
                {confirmLabel}
            </Button>
        </div>
    );
}