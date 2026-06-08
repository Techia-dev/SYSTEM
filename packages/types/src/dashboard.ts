export type DashboardStats = {
    totalCollectedCommissions: number;
    totalAcceptedCandidates: number;
    totalRejectedCandidates: number;
};

export type MonthlyAnalytics = {
    month: string;
    accepted: number;
    rejected: number;
    paidCommissions: number;
    pendingCommissions: number;
};
