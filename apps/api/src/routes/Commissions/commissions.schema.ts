import { z } from "zod";

/**
 * Commissions domain validation schemas
 */

const CommissionStatusEnum = z.enum(["pending", "paid"] as const);

export const ListCommissionsQuerySchema = z.object({
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

export const UpdateCommissionStatusDtoSchema = z.object({
    status: CommissionStatusEnum,
});

export type ValidatedListCommissionsQuery = z.infer<typeof ListCommissionsQuerySchema>;
export type ValidatedUpdateCommissionStatusDto = z.infer<typeof UpdateCommissionStatusDtoSchema>;
