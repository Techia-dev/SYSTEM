import { PageShell } from "@/components/layout/Sidebar";
import { StatCard } from "@/components/ui/StatCard";

export default function DashboardPage() {
  return (
    <PageShell title="Dashboard">
      <div className="grid grid-cols-4 gap-3 mb-6">
        <StatCard
          label="Candidates"
          value="24"
          sub="Total registered"
          trend={{ label: "+3 this week", direction: "up" }}
        />
        <StatCard
          label="Applications"
          value="41"
          sub="Active pipeline"
          trend={{ label: "+6 new", direction: "up" }}
        />
        <StatCard
          label="Commissions"
          value="EGP 28.4k"
          sub="Pending payout"
          trend={{ label: "3 overdue", direction: "down" }}
        />
        <StatCard
          label="Active Offers"
          value="7"
          sub="Hiring now"
          trend={{ label: "+2 new", direction: "up" }}
        />
      </div>
    </PageShell>
  );
}