import { api } from "@/lib/api";
import type { CreateOfferDto, UpdateOfferDto } from "@techia/types";

export const offersService = {
    list: () => api.offers.list(),
    create: (data: CreateOfferDto) => api.offers.create(data),
    update: (id: string, data: UpdateOfferDto) =>
        api.offers.update(id, data),
    deactivate: (id: string) => api.offers.deactivate(id),
};