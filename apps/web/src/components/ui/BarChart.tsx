import type { MonthlyAnalytics } from "@techia/types";
import { formatCurrency } from "@/lib/utils";

interface BarChartProps {
    data: MonthlyAnalytics[];
}

const SEGMENTS = [
    { key: "accepted" as const, color: "bg-emerald-400", label: "Accepted" },
    { key: "rejected" as const, color: "bg-red-400", label: "Rejected" },
    { key: "paidCommissions" as const, color: "bg-blue-500", label: "Paid commissions" },
    { key: "pendingCommissions" as const, color: "bg-amber-400", label: "Pending commissions" },
];

export function BarChart({ data }: BarChartProps) {
    if (data.length === 0) {
        return (
            <div className="bg-white rounded-xl border border-zinc-200 p-4">
                <h3 className="text-sm font-semibold text-zinc-800 mb-4">Monthly overview</h3>
                <p className="text-sm text-zinc-400">No data yet</p>
            </div>
        );
    }

    const totals = data.map((d) =>
        SEGMENTS.reduce((sum, s) => sum + d[s.key], 0)
    );
    const maxTotal = Math.max(...totals, 1);

    return (
        <div className="bg-white rounded-xl border border-zinc-200 p-4">
            <h3 className="text-sm font-semibold text-zinc-800 mb-4">Monthly overview</h3>

            <div className="flex flex-wrap gap-4 mb-4">
                {SEGMENTS.map((s) => (
                    <div key={s.key} className="flex items-center gap-1.5 text-xs text-zinc-500">
                        <span className={`w-2.5 h-2.5 rounded-sm ${s.color}`} />
                        {s.label}
                    </div>
                ))}
            </div>

            <div className="space-y-1">
                {data.map((d) => {
                    const total = totals[data.indexOf(d)];
                    return (
                        <div key={d.month} className="flex items-center gap-2 text-xs">
                            <span className="w-10 text-right text-zinc-400 shrink-0">
                                {d.month.slice(5)}
                            </span>
                            <div className="flex-1 h-6 bg-zinc-50 rounded flex overflow-hidden">
                                {SEGMENTS.map((s) => {
                                    const val = d[s.key];
                                    const pct = (val / maxTotal) * 100;
                                    if (pct < 1 && val > 0) {
                                        return (
                                            <div
                                                key={s.key}
                                                className={`${s.color} min-w-[4px]`}
                                                style={{ width: `${Math.max(pct, 2)}%` }}
                                                title={`${s.label}: ${s.key === "paidCommissions" || s.key === "pendingCommissions" ? formatCurrency(val) : val}`}
                                            />
                                        );
                                    }
                                    if (val === 0) return null;
                                    return (
                                        <div
                                            key={s.key}
                                            className={`${s.color}`}
                                            style={{ width: `${pct}%` }}
                                            title={`${s.label}: ${s.key === "paidCommissions" || s.key === "pendingCommissions" ? formatCurrency(val) : val}`}
                                        />
                                    );
                                })}
                            </div>
                            <span className="w-12 text-right text-zinc-500 shrink-0">
                                {total}
                            </span>
                        </div>
                    );
                })}
            </div>
        </div>
    );
}
