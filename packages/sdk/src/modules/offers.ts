import type {
    Offer,
    OfferWithCount,
    CreateOfferDto,
    UpdateOfferDto,
    CreateOfferResponse,
    PaginatedResponse,
} from "@techia/types";

import type { HttpClient } from "../client";

export class OffersResource {
    constructor(private client: HttpClient) { }

    /**
     * List offers with pagination
     */
    async list(): Promise<PaginatedResponse<Offer>> {
        return this.client.get<PaginatedResponse<Offer>>(
            "/offers"
        );
    }

    /**
     * Get offer details
     */
    async getById(id: string): Promise<OfferWithCount> {
        return this.client.get<OfferWithCount>(
            `/offers/${id}`
        );
    }

    /**
     * Create offer
     */
    async create(
        data: CreateOfferDto
    ): Promise<CreateOfferResponse> {
        return this.client.post<CreateOfferResponse>(
            "/offers",
            data
        );
    }

    /**
     * Update offer
     */
    async update(
        id: string,
        data: UpdateOfferDto
    ): Promise<Offer> {
        return this.client.put<Offer>(
            `/offers/${id}`,
            data
        );
    }

    /**
     * Soft delete offer
     */
    async deactivate(
        id: string
    ): Promise<{ message: string }> {
        return this.client.delete<{ message: string }>(
            `/offers/${id}`
        );
    }
}