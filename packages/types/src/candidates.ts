import type { CandidateLevel } from "./enums";

/* ================= ENTITY ================= */

export interface Candidate {
    id: string;
    name: string;
    phone: string;
    secondaryPhone: string | null;
    email: string | null;
    level: CandidateLevel;
    qualification: string | null;
    experience: string | null;
    cvUrl: string | null;
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

export interface UpdateCandidateDto {
    name?: string;
    phone?: string;
    secondaryPhone?: string | null;
    email?: string | null;
    level?: CandidateLevel;
    qualification?: string | null;
    experience?: string | null;
    cvUrl?: string | null;
}