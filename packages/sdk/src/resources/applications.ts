/**
 * Applications Resource Client
 */

import type { HttpClient } from "../client";
import type {
    Application,
    CreateApplicationDto,
    UpdateApplicationStatusDto,
    UpdateStatusResponse,
} from "@techia/types";

export type ListApplicationsParams = {
    page?: number;
    page_size?: number;
    status?: string;
};

export type ListApplicationsResult = {
    data: Application[];
    page: number;
    pageSize: number;
};

export class ApplicationsResource {
    constructor(private client: HttpClient) {}

    /**
     * List all applications with pagination and filtering
     */
    async list(params?: ListApplicationsParams): Promise<ListApplicationsResult> {
        const query = new URLSearchParams();
        if (params?.page) query.append("page", String(params.page));
        if (params?.page_size) query.append("page_size", String(params.page_size));
        if (params?.status) query.append("status", params.status);

        const queryString = query.toString();
        const path = `/applications${queryString ? `?${queryString}` : ""}`;

        return this.client.get<ListApplicationsResult>(path);
    }

    /**
     * Get an application by ID
     */
    async getById(id: string): Promise<Application> {
        return this.client.get(`/applications/${id}`);
    }

    /**
     * Create a new application
     */
    async create(data: CreateApplicationDto): Promise<{ id: string; message: string }> {
        return this.client.post(`/applications`, data);
    }

    /**
     * Update application status
     */
    async updateStatus(
        id: string,
        data: UpdateApplicationStatusDto
    ): Promise<UpdateStatusResponse> {
        return this.client.put(`/applications/${id}`, data);
    }
}
