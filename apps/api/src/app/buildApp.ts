import Fastify from "fastify";
import { config } from "../config";


// Routes
import candidateRoutes from "../routes/candidates/candidates.routes";
import applicationRoutes from "../routes/applications";
import offerRoutes from "../routes/offers/offers.routes";
import commissionRoutes from "../routes/Commissions/commissions.routes";
import { authRoutes } from "@techia/admin-api";

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
    // GLOBAL ERROR HANDLER (NO ANY)
    // ============================================================

    app.setErrorHandler((error, request, reply) => {
        app.log.error(error);

        // type narrowing (NO any, NO casting)
        const statusCode =
            typeof error === "object" &&
                error !== null &&
                "statusCode" in error &&
                typeof (error as { statusCode?: unknown }).statusCode === "number"
                ? (error as { statusCode: number }).statusCode
                : 500;

        const message =
            error instanceof Error ? error.message : "Internal Server Error";

        reply.status(statusCode).send({
            message,
        });
    });

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
        message: "ATS API Running 🚀",
    }));

    return app;
};