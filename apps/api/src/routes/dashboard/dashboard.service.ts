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
        const [acceptedByMonth, rejectedByMonth, paidByMonth, pendingByMonth] = await Promise.all([
            prisma.application.groupBy({
                by: ["createdAt"],
                where: { status: "accepted" },
                _count: { id: true },
            }) as unknown as Array<{ createdAt: Date; _count: { id: number } }>,
            prisma.application.groupBy({
                by: ["createdAt"],
                where: { status: "rejected" },
                _count: { id: true },
            }) as unknown as Array<{ createdAt: Date; _count: { id: number } }>,
            prisma.commission.groupBy({
                by: ["earnedAt"],
                where: { status: "paid" },
                _sum: { amount: true },
            }) as unknown as Array<{ earnedAt: Date; _sum: { amount: number | null } }>,
            prisma.commission.groupBy({
                by: ["earnedAt"],
                where: { status: "pending" },
                _sum: { amount: true },
            }) as unknown as Array<{ earnedAt: Date; _sum: { amount: number | null } }>,
        ]);

        const monthMap = new Map<string, MonthlyAnalytics>();

        function getMonth(date: Date): string {
            return date.toISOString().slice(0, 7);
        }

        function ensureEntry(month: string): MonthlyAnalytics {
            let entry = monthMap.get(month);
            if (!entry) {
                entry = { month, accepted: 0, rejected: 0, paidCommissions: 0, pendingCommissions: 0 };
                monthMap.set(month, entry);
            }
            return entry;
        }

        for (const item of acceptedByMonth) {
            ensureEntry(getMonth(item.createdAt)).accepted += item._count.id;
        }
        for (const item of rejectedByMonth) {
            ensureEntry(getMonth(item.createdAt)).rejected += item._count.id;
        }
        for (const item of paidByMonth) {
            ensureEntry(getMonth(item.earnedAt)).paidCommissions += item._sum.amount ?? 0;
        }
        for (const item of pendingByMonth) {
            ensureEntry(getMonth(item.earnedAt)).pendingCommissions += item._sum.amount ?? 0;
        }

        return Array.from(monthMap.values()).sort((a, b) => a.month.localeCompare(b.month));
    }
}
