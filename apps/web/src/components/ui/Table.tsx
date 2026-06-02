// ============================================================
// Table — جدول بيانات موحد مع loading و empty states
// ============================================================

// ── Sub-components (للاستخدام مع HTML table مباشرة) ──────────

export function Table({
    children,
    className = "",
}: {
    children: React.ReactNode;
    className?: string;
}) {
    return (
        <div className={`overflow-hidden rounded-xl border border-zinc-200 bg-white ${className}`}>
            <div className="overflow-x-auto">
                <table className="w-full text-sm border-collapse">{children}</table>
            </div>
        </div>
    );
}

export function TableHead({ children }: { children: React.ReactNode }) {
    return (
        <thead className="bg-zinc-50 border-b border-zinc-200">
            {children}
        </thead>
    );
}

export function Th({
    children,
    className = "",
}: {
    children?: React.ReactNode;
    className?: string;
}) {
    return (
        <th
            scope="col"
            className={[
                "px-4 py-2.5 text-left text-xs font-medium text-zinc-500",
                "uppercase tracking-wide whitespace-nowrap",
                className,
            ].join(" ")}
        >
            {children}
        </th>
    );
}

export function TableBody({ children }: { children: React.ReactNode }) {
    return <tbody className="divide-y divide-zinc-100">{children}</tbody>;
}

export function Tr({
    children,
    onClick,
    className = "",
}: {
    children: React.ReactNode;
    onClick?: () => void;
    className?: string;
}) {
    return (
        <tr
            onClick={onClick}
            className={[
                "transition-colors duration-100",
                onClick ? "cursor-pointer hover:bg-zinc-50" : "hover:bg-zinc-50/50",
                className,
            ].join(" ")}
        >
            {children}
        </tr>
    );
}

export function Td({
    children,
    className = "",
}: {
    children?: React.ReactNode;
    className?: string;
}) {
    return (
        <td className={`px-4 py-3 text-zinc-700 whitespace-nowrap ${className}`}>
            {children}
        </td>
    );
}

// ── Loading skeleton ──────────────────────────────────────────

export function TableSkeleton({ cols, rows = 5 }: { cols: number; rows?: number }) {
    return (
        <TableBody>
            {Array.from({ length: rows }).map((_, i) => (
                <Tr key={i}>
                    {Array.from({ length: cols }).map((_, j) => (
                        <Td key={j}>
                            <div
                                className="h-4 bg-zinc-100 rounded animate-pulse"
                                style={{ width: `${60 + ((i + j) * 17) % 30}%` }}
                            />
                        </Td>
                    ))}
                </Tr>
            ))}
        </TableBody>
    );
}

// ── Empty state ───────────────────────────────────────────────

export function TableEmpty({
    cols,
    message = "No data found",
    icon,
}: {
    cols: number;
    message?: string;
    icon?: React.ReactNode;
}) {
    return (
        <TableBody>
            <tr>
                <td colSpan={cols} className="px-4 py-14 text-center">
                    <div className="flex flex-col items-center gap-2">
                        {icon && (
                            <span className="text-zinc-300" aria-hidden="true">
                                {icon}
                            </span>
                        )}
                        <p className="text-sm text-zinc-400">{message}</p>
                    </div>
                </td>
            </tr>
        </TableBody>
    );
}

// ── Cell helpers (للاستخدام المتكرر) ─────────────────────────

/** خلية اسم + صورة رمزية (avatar) */
export function AvatarCell({
    name,
    sub,
}: {
    name: string;
    sub?: string;
}) {
    // أول حرفين من الاسم كـ initials
    const initials = name
        .split(" ")
        .slice(0, 2)
        .map((w) => w[0]?.toUpperCase() ?? "")
        .join("");

    return (
        <div className="flex items-center gap-2.5">
            <span
                className="w-7 h-7 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center text-xs font-medium shrink-0"
                aria-hidden="true"
            >
                {initials}
            </span>
            <div className="min-w-0">
                <p className="font-medium text-zinc-800 truncate">{name}</p>
                {sub && <p className="text-xs text-zinc-400 truncate">{sub}</p>}
            </div>
        </div>
    );
}

/** خلية مبلغ بالـ EGP */
export function AmountCell({ amount }: { amount: number }) {
    return (
        <span className="font-mono text-zinc-700">
            {new Intl.NumberFormat("en-EG", {
                style: "currency",
                currency: "EGP",
                minimumFractionDigits: 0,
            }).format(amount)}
        </span>
    );
}