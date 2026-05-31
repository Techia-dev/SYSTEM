// ============================================================
// StatCard — بطاقات الإحصائيات في الـ Dashboard
// ============================================================

interface StatCardProps {
    label: string;
    value: string | number;
    sub?: string;
    trend?: {
        label: string;
        direction: "up" | "down" | "neutral";
    };
    icon?: React.ReactNode;
}

const trendStyles = {
    up: "text-emerald-700 bg-emerald-50",
    down: "text-red-700    bg-red-50",
    neutral: "text-zinc-500   bg-zinc-100",
};

const trendIcons = {
    up: "↑",
    down: "↓",
    neutral: "—",
};

export function StatCard({ label, value, sub, trend, icon }: StatCardProps) {
    return (
        <div className="bg-white rounded-xl border border-zinc-200 p-4 flex flex-col gap-3">
            {/* Top row */}
            <div className="flex items-start justify-between">
                <p className="text-xs font-medium text-zinc-500 uppercase tracking-wide">
                    {label}
                </p>
                {icon && (
                    <span className="text-zinc-300 text-lg" aria-hidden="true">
                        {icon}
                    </span>
                )}
            </div>

            {/* Value */}
            <div>
                <p className="text-2xl font-semibold text-zinc-900 leading-none tracking-tight">
                    {value}
                </p>
                {sub && (
                    <p className="mt-1 text-xs text-zinc-400">{sub}</p>
                )}
            </div>

            {/* Trend */}
            {trend && (
                <span
                    className={[
                        "self-start inline-flex items-center gap-1",
                        "text-xs font-medium px-2 py-0.5 rounded-full",
                        trendStyles[trend.direction],
                    ].join(" ")}
                >
                    <span aria-hidden="true">{trendIcons[trend.direction]}</span>
                    {trend.label}
                </span>
            )}
        </div>
    );
}