import { z } from "zod";

/**
 * Applications domain validation schemas
 */

const ApplicationStatusEnum = z.enum(["applied", "interview", "accepted", "rejected"] as const);

export const ListApplicationsQuerySchema = z.object({
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
    status: z.string().optional(),
});

export const CreateApplicationDtoSchema = z.object({
    candidateId: z.string().cuid("invalid candidateId"),
    offerId: z.string().cuid("invalid offerId"),
    source: z.string().optional(),
    assignedTo: z.string().optional(),
});

export const UpdateApplicationStatusDtoSchema = z.object({
    status: ApplicationStatusEnum,
});

export type ValidatedListApplicationsQuery = z.infer<typeof ListApplicationsQuerySchema>;
export type ValidatedCreateApplicationDto = z.infer<typeof CreateApplicationDtoSchema>;
export type ValidatedUpdateApplicationStatusDto = z.infer<typeof UpdateApplicationStatusDtoSchema>;
