import { z } from "zod";

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
    secondaryPhone: z.string().max(20).optional(),
    email: z.string().email("invalid email").optional(),
    level: CandidateLevelEnum.optional(),
    qualification: z.string().optional(),
    experience: z.string().optional(),
});

export const UpdateCandidateDtoSchema = z.object({
    name: z.string().min(1).max(255).optional(),
    phone: z.string().min(1).max(20).optional(),
    secondaryPhone: z.string().max(20).optional().nullable(),
    email: z.string().email("invalid email").optional().nullable(),
    level: CandidateLevelEnum.optional(),
    qualification: z.string().optional().nullable(),
    experience: z.string().optional().nullable(),
    cvUrl: z.string().optional().nullable(),
});

export type ValidatedListCandidatesQuery = z.infer<typeof ListCandidatesQuerySchema>;
export type ValidatedCreateCandidateDto = z.infer<typeof CreateCandidateDtoSchema>;
export type ValidatedUpdateCandidateDto = z.infer<typeof UpdateCandidateDtoSchema>;

