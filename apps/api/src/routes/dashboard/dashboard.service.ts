import { prisma } from "@techia/db";
import type { DashboardStats, MonthlyAnalytics } from "@techia/types";

export class DashboardService {
    async getStats(): Promise<DashboardStats> {
        const [collectedAgg, acceptedCount, rejectedCount] = await Promise.all([
            prisma.commission.aggregate({
                where: { status: "paid" },
                _sum: { amount: true },
            }),
            prisma.application.count({
                where: { status: "accepted" },
            }),
            prisma.application.count({
                where: { status: "rejected" },
            }),
        ]);

        return {
            totalCollectedCommissions: collectedAgg._sum.amount ?? 0,
            totalAcceptedCandidates: acceptedCount,
            totalRejectedCandidates: rejectedCount,
        };
    }

    async getAnalytics(): Promise<MonthlyAnalytics[]> {
        const applications = await prisma.application.findMany({
            select: { status: true, createdAt: true },
        });
        const commissions = await prisma.commission.findMany({
            select: { status: true, amount: true, earnedAt: true },
        });

        const monthMap = new Map<string, MonthlyAnalytics>();

        for (const app of applications) {
            const month = app.createdAt.toISOString().slice(0, 7);
            const entry = monthMap.get(month) ?? { month, accepted: 0, rejected: 0, paidCommissions: 0, pendingCommissions: 0 };
            if (app.status === "accepted") entry.accepted++;
            else if (app.status === "rejected") entry.rejected++;
            monthMap.set(month, entry);
        }

        for (const c of commissions) {
            const month = c.earnedAt.toISOString().slice(0, 7);
            const entry = monthMap.get(month) ?? { month, accepted: 0, rejected: 0, paidCommissions: 0, pendingCommissions: 0 };
            if (c.status === "paid") entry.paidCommissions += c.amount;
            else if (c.status === "pending") entry.pendingCommissions += c.amount;
            monthMap.set(month, entry);
        }

        return Array.from(monthMap.values()).sort((a, b) => a.month.localeCompare(b.month));
    }
}
