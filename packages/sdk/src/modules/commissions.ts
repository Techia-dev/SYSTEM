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

    list(): Promise<PaginatedResponse<CommissionWithRelations>> {
        return this.client.get("/commissions");
    }

    getById(
        id: string
    ): Promise<Commission & { candidate: Candidate; offer: Offer }> {
        return this.client.get(`/commissions/${id}`);
    }

    updateStatus(
        id: string,
        data: UpdateCommissionStatusDto
    ): Promise<UpdateCommissionResponse> {
        return this.client.patch(`/commissions/${id}/status`, data);
    }
}