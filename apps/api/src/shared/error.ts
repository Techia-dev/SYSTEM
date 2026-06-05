// src/shared/error.ts

/**
 * Base application error class
 * All domain errors extend this
 */
export class AppError extends Error {
    public statusCode: number;
    public isOperational: boolean;
    public code?: string;

    constructor(message: string, statusCode = 500, code?: string) {
        super(message);

        this.statusCode = statusCode;
        this.isOperational = true;
        this.code = code;

        Error.captureStackTrace(this, this.constructor);
    }
}

/**
 * Validation error (400)
 */
export class ValidationError extends AppError {
    constructor(message: string, public fields?: Record<string, string[]>) {
        super(message, 400, "VALIDATION_ERROR");
    }
}

/**
 * Not found error (404)
 */
export class NotFoundError extends AppError {
    constructor(resource: string, identifier?: string) {
        super(
            `${resource}${identifier ? ` with id ${identifier}` : ""} not found`,
            404,
            "NOT_FOUND"
        );
    }
}

/**
 * Conflict error (409)
 */
export class ConflictError extends AppError {
    constructor(message: string) {
        super(message, 409, "CONFLICT");
    }
}

/**
 * Unauthorized error (401)
 */
export class UnauthorizedError extends AppError {
    constructor(message = "Unauthorized") {
        super(message, 401, "UNAUTHORIZED");
    }
}

/**
 * Forbidden error (403)
 */
export class ForbiddenError extends AppError {
    constructor(message = "Forbidden") {
        super(message, 403, "FORBIDDEN");
    }
}