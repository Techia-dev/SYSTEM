/**
 * API Response Standardization
 * Provides consistent response format across all endpoints
 */

export type ApiSuccessResponse<T> = {
    success: true;
    data: T;
    meta?: Record<string, unknown>;
};

export type ApiErrorResponse = {
    success: false;
    error: {
        message: string;
        code: string;
        fields?: Record<string, string[]>;
    };
};

export type ApiResponse<T> = ApiSuccessResponse<T> | ApiErrorResponse;

/**
 * Create a success response
 */
export function successResponse<T>(data: T, meta?: Record<string, unknown>): ApiSuccessResponse<T> {
    return {
        success: true,
        data,
        ...(meta && { meta }),
    };
}

/**
 * Create an error response
 */
export function errorResponse(
    message: string,
    code: string,
    fields?: Record<string, string[]>
): ApiErrorResponse {
    return {
        success: false,
        error: {
            message,
            code,
            ...(fields && { fields }),
        },
    };
}
