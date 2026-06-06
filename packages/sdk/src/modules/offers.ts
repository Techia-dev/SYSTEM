import type {
    Offer,
    OfferWithCount,
    CreateOfferDto,
    UpdateOfferDto,
    PaginatedResponse,
} from "@techia/types";

import type { HttpClient } from "../client";

export class OffersResource {
    constructor(private client: HttpClient) { }

    list(): Promise<PaginatedResponse<Offer>> {
        return this.client.get("/offers");
    }

    getById(id: string): Promise<OfferWithCount> {
        return this.client.get(`/offers/${id}`);
    }

    create(data: CreateOfferDto) {
        return this.client.post("/offers", data);
    }

    update(id: string, data: UpdateOfferDto) {
        return this.client.put(`/offers/${id}`, data);
    }

    deactivate(id: string) {
        return this.client.delete(`/offers/${id}`);
    }
}