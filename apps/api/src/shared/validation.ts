import { ZodError, ZodSchema } from "zod";
import { ValidationError } from "./error";

/**
 * Validation helper function
 * Throws ValidationError if validation fails
 */
export function validate<T>(schema: ZodSchema<T>, data: unknown): T {
    try {
        return schema.parse(data) as T;
    } catch (error) {
        if (error instanceof ZodError) {
            const fields: Record<string, string[]> = {};
            error.issues.forEach((issue) => {
                const path = issue.path.join(".");
                if (!fields[path]) fields[path] = [];
                fields[path].push(issue.message);
            });
            throw new ValidationError("Validation failed", fields);
        }
        throw error;
    }
}
