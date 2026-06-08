import type {
    ApplicationWithRelations,
    ApplicationFull,
    CreateApplicationDto,
    UpdateApplicationStatusDto,
    UpdateStatusResponse,
    PaginatedResponse,
    CreateApplicationResponse,
} from "@techia/types";

import type { HttpClient } from "../client";

export class ApplicationsResource {
    constructor(private client: HttpClient) { }

    /**
     * List applications with pagination
     */
    async list(): Promise<PaginatedResponse<ApplicationWithRelations>> {
        return this.client.get<PaginatedResponse<ApplicationWithRelations>>(
            "/applications"
        );
    }

    /**
     * Get application details
     */
    async getById(id: string): Promise<ApplicationFull> {
        return this.client.get<ApplicationFull>(
            `/applications/${id}`
        );
    }

    /**
     * Create application
     */
    async create(
        data: CreateApplicationDto
    ): Promise<CreateApplicationResponse> {
        return this.client.post<CreateApplicationResponse>(
            "/applications",
            data
        );
    }

    /**
     * Delete application
     */
    async delete(id: string): Promise<{ message: string }> {
        return this.client.delete<{ message: string }>(
            `/applications/${id}`
        );
    }

    /**
     * Update application status
     */
    async updateStatus(
        id: string,
        data: UpdateApplicationStatusDto
    ): Promise<UpdateStatusResponse> {
        return this.client.put<UpdateStatusResponse>(
            `/applications/${id}/status`,
            data
        );
    }
}