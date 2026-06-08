"use client";

import { PageShell } from "@/components/layout/Sidebar";
import { StatCard } from "@/components/ui/StatCard";
import { BarChart } from "@/components/ui/BarChart";
import { formatCurrency } from "@/lib/utils";
import { useOffers, useDashboardStats, useDashboardAnalytics } from "@/lib/hooks";

export default function DashboardPage() {
  const { data: offers = [], isLoading: ol } = useOffers();
  const { data: stats, isLoading: sl } = useDashboardStats();
  const { data: analytics = [], isLoading: al } = useDashboardAnalytics();

  const loading = ol || sl || al;

  const activeOffers = offers.filter((o) => o.isActive);

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
            <StatCard label="Collected Commissions" value={formatCurrency(stats?.totalCollectedCommissions ?? 0)} sub="Total paid out" />
            <StatCard label="Accepted" value={String(stats?.totalAcceptedCandidates ?? 0)} sub="Candidates hired" />
            <StatCard label="Rejected" value={String(stats?.totalRejectedCandidates ?? 0)} sub="Candidates declined" />
            <StatCard label="Active Offers" value={String(activeOffers.length)} sub="Currently hiring" />
          </>
        )}
      </div>

      <BarChart data={analytics} />
    </PageShell>
  );
}
