import { sdk } from "@/lib/sdk";
import type { CreateCandidateDto } from "@techia/types";

export const candidatesService = {
    list: () => sdk.candidates.list(),
    create: (data: CreateCandidateDto) => sdk.candidates.create(data),
};