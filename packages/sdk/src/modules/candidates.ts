/**
 * Candidates Resource Client
 */

import type { HttpClient } from "../client";
import type {
    Candidate,
    CreateCandidateDto,
    ListCandidatesResponse,
} from "@techia/types";

export class CandidatesResource {
    constructor(private client: HttpClient) {}

    /**
     * List all candidates with pagination and filtering
     */
    async list(params?: {
        page?: number;
        page_size?: number;
        search?: string;
        level?: string;
    }): Promise<ListCandidatesResponse> {
        const query = new URLSearchParams();
        if (params?.page) query.append("page", String(params.page));
        if (params?.page_size) query.append("page_size", String(params.page_size));
        if (params?.search) query.append("search", params.search);
        if (params?.level) query.append("level", params.level);

        const queryString = query.toString();
        const path = `/candidates${queryString ? `?${queryString}` : ""}`;

        return this.client.get<ListCandidatesResponse>(path);
    }

    /**
     * Create a new candidate
     */
    async create(data: CreateCandidateDto): Promise<{ id: string; message: string }> {
        return this.client.post(`/candidates`, data);
    }

    /**
     * Get a candidate by ID
     */
    async getById(id: string): Promise<Candidate> {
        return this.client.get(`/candidates/${id}`);
    }
}
