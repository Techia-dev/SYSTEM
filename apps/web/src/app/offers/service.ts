import { sdk } from "@/lib/sdk";
import type { CreateOfferDto, UpdateOfferDto } from "@techia/types";

export const offersService = {
    list: () => sdk.offers.list(),
    create: (data: CreateOfferDto) => sdk.offers.create(data),
    update: (id: string, data: UpdateOfferDto) =>
        sdk.offers.update(id, data),
    deactivate: (id: string) => sdk.offers.deactivate(id),
};