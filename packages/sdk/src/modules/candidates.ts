import type {
    PaginatedResponse,
    Candidate,
    CreateCandidateDto,
} from "@techia/types";

import type { HttpClient } from "../client";

export class CandidatesResource {
    constructor(private client: HttpClient) { }

    async list(params?: {
        page?: number;
        page_size?: number;
        search?: string;
        level?: string;
    }): Promise<PaginatedResponse<Candidate>> {
        const query = new URLSearchParams();

        if (params?.page) query.append("page", String(params.page));
        if (params?.page_size) query.append("page_size", String(params.page_size));
        if (params?.search) query.append("search", params.search);
        if (params?.level) query.append("level", params.level);

        const qs = query.toString();
        const path = `/candidates${qs ? `?${qs}` : ""}`;

        return this.client.get<PaginatedResponse<Candidate>>(path);
    }

    async create(
        data: CreateCandidateDto
    ): Promise<{ id: string; message: string }> {
        return this.client.post<{ id: string; message: string }>(
            "/candidates",
            data
        );
    }

    async getById(id: string): Promise<Candidate> {
        return this.client.get<Candidate>(`/candidates/${id}`);
    }
}