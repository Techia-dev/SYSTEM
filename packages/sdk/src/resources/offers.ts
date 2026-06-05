/**
 * Offers Resource Client
 */

import type { HttpClient } from "../client";
import type {
    Offer,
    CreateOfferDto,
    UpdateOfferDto,
} from "@techia/types";

export type ListOffersParams = {
    page?: number;
    page_size?: number;
};

export type ListOffersResult = {
    data: Offer[];
    page: number;
    pageSize: number;
    total: number;
};

export class OffersResource {
    constructor(private client: HttpClient) {}

    /**
     * List all offers with pagination
     */
    async list(params?: ListOffersParams): Promise<ListOffersResult> {
        const query = new URLSearchParams();
        if (params?.page) query.append("page", String(params.page));
        if (params?.page_size) query.append("page_size", String(params.page_size));

        const queryString = query.toString();
        const path = `/offers${queryString ? `?${queryString}` : ""}`;

        return this.client.get<ListOffersResult>(path);
    }

    /**
     * Get an offer by ID
     */
    async getById(id: string): Promise<Offer> {
        return this.client.get(`/offers/${id}`);
    }

    /**
     * Create a new offer
     */
    async create(data: CreateOfferDto): Promise<{ id: string; message: string }> {
        return this.client.post(`/offers`, data);
    }

    /**
     * Update an offer
     */
    async update(id: string, data: UpdateOfferDto): Promise<Offer> {
        return this.client.put(`/offers/${id}`, data);
    }

    /**
     * Delete an offer
     */
    async delete(id: string): Promise<{ success: boolean; message: string }> {
        return this.client.delete(`/offers/${id}`);
    }
}
