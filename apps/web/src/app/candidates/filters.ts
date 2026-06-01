import type { Candidate, CandidateLevel } from "@techia/types";

export function filterCandidates(
    data: Candidate[],
    search: string,
    level: CandidateLevel | "all"
) {
    const term = search.toLowerCase();

    return data.filter((c) => {
        const matchLevel = level === "all" || c.level === level;

        const matchSearch =
            !term ||
            c.name.toLowerCase().includes(term) ||
            c.phone.includes(term) ||
            (c.email ?? "").toLowerCase().includes(term);

        return matchLevel && matchSearch;
    });
}