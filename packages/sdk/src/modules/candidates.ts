import type {
    PaginatedResponse,
    Candidate,
    CreateCandidateDto,
    UpdateCandidateDto,
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

    async update(
        id: string,
        data: UpdateCandidateDto
    ): Promise<{ id: string; message: string }> {
        return this.client.put<{ id: string; message: string }>(
            `/candidates/${id}`,
            data
        );
    }

    async delete(id: string): Promise<{ message: string }> {
        return this.client.delete<{ message: string }>(`/candidates/${id}`);
    }

    async uploadCv(id: string, file: File): Promise<{ cvUrl: string }> {
        const formData = new FormData();
        formData.append("cv", file);
        return this.client.post<{ cvUrl: string }>(
            `/candidates/${id}/cv`,
            formData
        );
    }
}
