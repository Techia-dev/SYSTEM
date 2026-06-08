import Fastify from "fastify";
import cors from "@fastify/cors";
import rateLimit from "@fastify/rate-limit";
import { config } from "../config";

// Plugins
import prismaPlugin from "../plugins/prisma.plugin";
import { authPlugin } from "@techia/admin-api";

// Routes
import candidateRoutes from "../routes/candidates/candidates.routes";
import applicationRoutes from "../routes/applications";
import offerRoutes from "../routes/offers/offers.routes";
import commissionRoutes from "../routes/commissions/commissions.routes";
import { authRoutes } from "@techia/admin-api";

// Shared
import { AppError, ValidationError } from "../shared/error";
import { errorResponse } from "../shared/response";

// Workers
import { registerWorkers } from "../workers";

const corsOrigins = config.corsOrigins.length > 0
    ? config.corsOrigins
    : ["http://localhost:3000"];

export const buildApp = () => {
    const app = Fastify({
        logger:
            config.nodeEnv === "test"
                ? {
                    transport: {
                        target: "pino-pretty",
                        options: {
                            translateTime: "HH:MM:ss",
                            ignore: "pid,hostname",
                            colorize: true,
                        },
                    },
                }
                : true,
    });

    // ============================================================
    // GLOBAL ERROR HANDLER
    // ============================================================

    app.setErrorHandler((error, _request, reply) => {
        app.log.error(error);

        if (error instanceof AppError) {
            const fields = error instanceof ValidationError ? error.fields : undefined;
            return reply
                .status(error.statusCode)
                .send(errorResponse(error.message, error.code ?? "APP_ERROR", fields));
        }

        const statusCode = (error as Record<string, number>).statusCode ?? 500;
        const message = error instanceof Error ? error.message : "Internal Server Error";

        reply.status(statusCode).send(errorResponse(message, "UNKNOWN_ERROR"));
    });

    // ============================================================
    // CORS
    // ============================================================

    app.register(cors, {
        origin: corsOrigins,
        credentials: true,
        methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    });

    // ============================================================
    // RATE LIMIT (before auth & routes)
    // ============================================================

    app.register(rateLimit, {
        global: true,
        max: 100,
        timeWindow: "1 minute",
    });

    // ============================================================
    // PLUGINS (order matters: prisma → auth → routes)
    // ============================================================

    app.register(prismaPlugin);

    app.register(authPlugin, {
        secret: config.jwtSecret,
        accessTokenTtl: config.jwtAccessTokenTtl,
    });

    // ============================================================
    // WORKERS
    // ============================================================

    registerWorkers();

    // ============================================================
    // ROUTES
    // ============================================================

    app.register(authRoutes, { prefix: "/api/auth" });
    app.register(candidateRoutes, { prefix: "/api/candidates" });
    app.register(applicationRoutes, { prefix: "/api/applications" });
    app.register(offerRoutes, { prefix: "/api/offers" });
    app.register(commissionRoutes, { prefix: "/api/commissions" });

    // ============================================================
    // CORE ENDPOINTS
    // ============================================================

    app.get("/health", async () => ({
        status: "ok",
        env: config.nodeEnv,
        timestamp: new Date().toISOString(),
    }));

    app.get("/", async () => ({
        message: "ATS API Running",
    }));

    return app;
};