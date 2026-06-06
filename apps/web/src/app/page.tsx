"use client";

import { useCallback, useEffect, useState } from "react";
import { PageShell } from "@/components/layout/Sidebar";
import { StatCard } from "@/components/ui/StatCard";
import { api } from "@/lib/api";
import { formatCurrency } from "@/lib/utils";


interface DashboardStats {
  candidates: number;
  applications: number;
  activeOffers: number;
  pendingCommissions: number;
  pendingCommissionsAmount: number;
  overdueCount: number;
}

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    try {
      const [candidates, applications, offers, commissions] = await Promise.all([
        api.candidates.list(),
        api.applications.list(),
        api.offers.list(),
        api.commissions.list(),
      ]);

      const activeOffers = offers.filter((o) => o.isActive);
      const pendingCommissions = commissions.filter((c) => c.status === "pending");
      const overdue = commissions.filter(
        (c) => c.status === "pending" && new Date(c.dueDate) < new Date(),
      );

      setStats({
        candidates: candidates.length,
        applications: applications.length,
        activeOffers: activeOffers.length,
        pendingCommissions: pendingCommissions.length,
        pendingCommissionsAmount: pendingCommissions.reduce((sum, c) => sum + c.amount, 0),
        overdueCount: overdue.length,
      });
    } catch {
      setStats(null);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

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
        ) : stats ? (
          <>
            <StatCard
              label="Candidates"
              value={String(stats.candidates)}
              sub="Total registered"
            />
            <StatCard
              label="Applications"
              value={String(stats.applications)}
              sub="Total applications"
            />
            <StatCard
              label="Commissions"
              value={formatCurrency(stats.pendingCommissionsAmount)}
              sub={`${stats.pendingCommissions} pending payout`}
              trend={
                stats.overdueCount > 0
                  ? { label: `${stats.overdueCount} overdue`, direction: "down" }
                  : undefined
              }
            />
            <StatCard
              label="Active Offers"
              value={String(stats.activeOffers)}
              sub="Currently hiring"
            />
          </>
        ) : (
          <div className="col-span-4 text-center text-sm text-zinc-400 py-10">
            Failed to load dashboard data.
          </div>
        )}
      </div>
    </PageShell>
  );
}
