import { api } from "@/lib/api";
import type { CreateCandidateDto } from "@techia/types";

export const candidatesService = {
    list: () => api.candidates.list(),
    create: (data: CreateCandidateDto) => api.candidates.create(data),
};