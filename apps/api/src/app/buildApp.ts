import Fastify from "fastify";
import cors from "@fastify/cors";
import { config } from "../config";

// Plugins
import prismaPlugin from "../plugins/prisma.plugin";
import { authPlugin } from "@techia/admin-api";

// Routes
import candidateRoutes from "../routes/candidates/candidates.routes";
import applicationRoutes from "../routes/applications";
import offerRoutes from "../routes/offers/offers.routes";
import commissionRoutes from "../routes/Commissions/commissions.routes";
import { authRoutes } from "@techia/admin-api";

// Workers
import { registerWorkers } from "../workers";

export const buildApp = () => {
    const app = Fastify({
        logger:
            config.nodeEnv === "development"
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

        const statusCode =
            typeof error === "object" &&
                error !== null &&
                "statusCode" in error &&
                typeof (error as Record<string, unknown>).statusCode === "number"
                ? (error as Record<string, number>).statusCode
                : 500;

        const message =
            error instanceof Error ? error.message : "Internal Server Error";

        reply.status(statusCode).send({
            message,
        });
    });

    // ============================================================
    // CORS (FIX for OPTIONS 404 + login failure)
    // ============================================================

    app.register(cors, {
        origin: [
            "http://localhost:3000",
        ],
        credentials: true,
        methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
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