import type { CandidateLevel } from "./enums";

/* ================= ENTITY ================= */

export interface Candidate {
    id: string;
    name: string;
    phone: string;
    email: string | null;
    level: CandidateLevel;
    createdAt: string;
    updatedAt: string;
}

/* ================= DTOs ================= */

export interface CreateCandidateDto {
    name: string;
    phone: string;
    email?: string;
    level?: CandidateLevel;
}

export interface ListCandidatesQueryDto {
    page?: string;
    page_size?: string;
    search?: string;
    level?: CandidateLevel;
}

export interface ListCandidatesResponse {
    data: Candidate[];
    total: number;
    page: number;
    pageSize: number;
    totalPages: number;
}

export interface CreateCandidateResponse {
    id: string;
    message: string;
}