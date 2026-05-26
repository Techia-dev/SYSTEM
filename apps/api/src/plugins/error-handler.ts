import { FastifyInstance, FastifyError } from "fastify";
import { Prisma } from "@prisma/client";

// ============================================================
// Error Handler Plugin
// بيعمل error responses موحدة لكل الـ routes
// ============================================================

export default async function errorHandlerPlugin(fastify: FastifyInstance) {
    fastify.setErrorHandler((error: FastifyError, request, reply) => {
        fastify.log.error(error);

        // Prisma: record not found
        if (error instanceof Prisma.PrismaClientKnownRequestError) {
            if (error.code === "P2025") {
                return reply.status(404).send({
                    success: false,
                    error: "Record not found",
                });
            }

            // Prisma: unique constraint violation
            if (error.code === "P2002") {
                return reply.status(409).send({
                    success: false,
                    error: "Record already exists",
                });
            }
        }

        // Validation errors من Fastify نفسه
        if (error.validation) {
            return reply.status(400).send({
                success: false,
                error: "Validation failed",
                details: error.validation,
            });
        }

        // باقي الـ errors
        const statusCode = error.statusCode ?? 500;
        return reply.status(statusCode).send({
            success: false,
            error: error.message || "Internal server error",
        });
    });

    // 404 handler للـ routes اللي مش موجودة
    fastify.setNotFoundHandler((request, reply) => {
        reply.status(404).send({
            success: false,
            error: `Route ${request.method} ${request.url} not found`,
        });
    });
}