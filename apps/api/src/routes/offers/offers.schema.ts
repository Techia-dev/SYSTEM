import { z } from "zod";

/**
 * Offers domain validation schemas
 */

export const ListOffersQuerySchema = z.object({
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
});

export const CreateOfferDtoSchema = z.object({
    title: z.string().min(1, "title is required").max(255),
    company: z.string().max(255).optional(),
    description: z.string().optional(),
    commission: z.number().min(0).optional(),
    commissionDelay: z.number().int().min(0).optional(),
    isActive: z.boolean().optional(),
});

export const UpdateOfferDtoSchema = z.object({
    title: z.string().min(1).max(255).optional(),
    company: z.string().max(255).optional(),
    description: z.string().optional(),
    commission: z.number().min(0).optional(),
    commissionDelay: z.number().int().min(0).optional(),
    isActive: z.boolean().optional(),
});

export type ValidatedListOffersQuery = z.infer<typeof ListOffersQuerySchema>;
export type ValidatedCreateOfferDto = z.infer<typeof CreateOfferDtoSchema>;
export type ValidatedUpdateOfferDto = z.infer<typeof UpdateOfferDtoSchema>;
