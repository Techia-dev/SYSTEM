import type { Offer } from "@techia/types";

export function filterOffers(
    data: Offer[],
    search: string,
    showInactive: boolean
) {
    const term = search.toLowerCase();

    return data.filter((o) => {
        const matchActive = showInactive || o.isActive;

        const matchSearch =
            !term ||
            o.title.toLowerCase().includes(term) ||
            (o.company ?? "").toLowerCase().includes(term);

        return matchActive && matchSearch;
    });
}