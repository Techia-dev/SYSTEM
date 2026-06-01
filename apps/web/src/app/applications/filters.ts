import type { ApplicationWithRelations, ApplicationStatus } from "@techia/types";

export function filterApplications(
    data: ApplicationWithRelations[],
    search: string,
    status: ApplicationStatus | "all"
) {
    const term = search.toLowerCase();

    return data.filter((a) => {
        const matchStatus = status === "all" || a.status === status;

        const matchSearch =
            !term ||
            a.candidate.name.toLowerCase().includes(term) ||
            a.offer.title.toLowerCase().includes(term);

        return matchStatus && matchSearch;
    });
}