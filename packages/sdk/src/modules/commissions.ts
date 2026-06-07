import type {
    Commission,
    CommissionWithRelations,
    UpdateCommissionStatusDto,
    UpdateCommissionResponse,
    PaginatedResponse,
    Candidate,
    Offer,
} from "@techia/types";

import type { HttpClient } from "../client";

export class CommissionsResource {
    constructor(private client: HttpClient) { }

    /**
     * List commissions with pagination
     */
    async list(): Promise<PaginatedResponse<CommissionWithRelations>> {
        return this.client.get<PaginatedResponse<CommissionWithRelations>>(
            "/commissions"
        );
    }

    /**
     * Get commission by ID
     */
    async getById(
        id: string
    ): Promise<Commission & { candidate: Candidate; offer: Offer }> {
        return this.client.get<
            Commission & { candidate: Candidate; offer: Offer }
        >(`/commissions/${id}`);
    }

    /**
     * Update commission status
     */
    async updateStatus(
        id: string,
        data: UpdateCommissionStatusDto
    ): Promise<UpdateCommissionResponse> {
        return this.client.patch<UpdateCommissionResponse>(
            `/commissions/${id}/status`,
            data
        );
    }
}