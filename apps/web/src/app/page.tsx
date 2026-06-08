"use client";

import { PageShell } from "@/components/layout/Sidebar";
import { StatCard } from "@/components/ui/StatCard";
import { formatCurrency } from "@/lib/utils";
import { useCandidates, useApplications, useOffers, useCommissions } from "@/lib/hooks";

export default function DashboardPage() {
  const { data: candidates = [], isLoading: cl } = useCandidates();
  const { data: applications = [], isLoading: al } = useApplications();
  const { data: offers = [], isLoading: ol } = useOffers();
  const { data: commissions = [], isLoading: col } = useCommissions();

  const loading = cl || al || ol || col;

  const activeOffers = offers.filter((o) => o.isActive);
  const pendingCommissions = commissions.filter((c) => c.status === "pending");
  const overdue = commissions.filter(
    (c) => c.status === "pending" && new Date(c.dueDate) < new Date(),
  );

  return (
    <PageShell title="Dashboard">
      <div className="grid grid-cols-4 gap-3 mb-6">
        {loading ? (
          <>
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="bg-white rounded-xl border border-zinc-200 p-4 space-y-3">
                <div className="h-3 w-20 bg-zinc-100 rounded animate-pulse" />
                <div className="h-7 w-16 bg-zinc-100 rounded animate-pulse" />
                <div className="h-3 w-24 bg-zinc-100 rounded animate-pulse" />
              </div>
            ))}
          </>
        ) : (
          <>
            <StatCard label="Candidates" value={String(candidates.length)} sub="Total registered" />
            <StatCard label="Applications" value={String(applications.length)} sub="Total applications" />
            <StatCard
              label="Commissions"
              value={formatCurrency(pendingCommissions.reduce((s, c) => s + c.amount, 0))}
              sub={`${pendingCommissions.length} pending payout`}
              trend={overdue.length > 0 ? { label: `${overdue.length} overdue`, direction: "down" } : undefined}
            />
            <StatCard label="Active Offers" value={String(activeOffers.length)} sub="Currently hiring" />
          </>
        )}
      </div>
    </PageShell>
  );
}
