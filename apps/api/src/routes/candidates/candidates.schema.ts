import { z } from "zod";
import type { CandidateLevel } from "@techia/types";

/**
 * Candidate domain validation schemas
 */

const CandidateLevelEnum = z.enum(["junior", "mid", "senior", "lead"] as const);

export const ListCandidatesQuerySchema = z.object({
    page: z
        .string()
        .optional()
        .refine(
            (val) => !val || Number.isInteger(Number(val)),
            "page must be an integer"
        ),
    page_size: z
        .string()
        .optional()
        .refine(
            (val) => !val || Number.isInteger(Number(val)),
            "page_size must be an integer"
        ),
    search: z.string().optional(),
    level: CandidateLevelEnum.optional(),
});

export const CreateCandidateDtoSchema = z.object({
    name: z.string().min(1, "name is required").max(255),
    phone: z.string().min(1, "phone is required").max(20),
    email: z.string().email("invalid email").optional(),
    level: CandidateLevelEnum.optional(),
});

export type ValidatedListCandidatesQuery = z.infer<typeof ListCandidatesQuerySchema>;
export type ValidatedCreateCandidateDto = z.infer<typeof CreateCandidateDtoSchema>;

