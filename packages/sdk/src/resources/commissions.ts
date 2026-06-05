/**
 * Commissions Resource Client
 */

import type { HttpClient } from "../client";
import type {
    Commission,
    UpdateCommissionStatusDto,
    UpdateCommissionResponse,
} from "@techia/types";

export type ListCommissionsParams = {
    page?: number;
    page_size?: number;
    status?: string;
};

export type ListCommissionsResult = {
    data: Commission[];
    page: number;
    pageSize: number;
    total: number;
};

export class CommissionsResource {
    constructor(private client: HttpClient) {}

    /**
     * List all commissions with pagination and filtering
     */
    async list(params?: ListCommissionsParams): Promise<ListCommissionsResult> {
        const query = new URLSearchParams();
        if (params?.page) query.append("page", String(params.page));
        if (params?.page_size) query.append("page_size", String(params.page_size));
        if (params?.status) query.append("status", params.status);

        const queryString = query.toString();
        const path = `/commissions${queryString ? `?${queryString}` : ""}`;

        return this.client.get<ListCommissionsResult>(path);
    }

    /**
     * Get a commission by ID
     */
    async getById(id: string): Promise<Commission> {
        return this.client.get(`/commissions/${id}`);
    }

    /**
     * Update commission status
     */
    async updateStatus(
        id: string,
        data: UpdateCommissionStatusDto
    ): Promise<UpdateCommissionResponse> {
        return this.client.put(`/commissions/${id}`, data);
    }
}
