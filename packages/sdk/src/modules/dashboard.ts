import type { DashboardStats, MonthlyAnalytics } from "@techia/types";
import type { HttpClient } from "../client";

export class DashboardResource {
    constructor(private client: HttpClient) { }

    async getStats(): Promise<DashboardStats> {
        return this.client.get<DashboardStats>("/dashboard/stats");
    }

    async getAnalytics(): Promise<MonthlyAnalytics[]> {
        return this.client.get<MonthlyAnalytics[]>("/dashboard/analytics");
    }
}
