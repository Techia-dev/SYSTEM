import Fastify from "fastify";
import { config } from "../config";

// Plugins
import databasePlugin from "../plugins/database";
import corsPlugin from "../plugins/cors";
import errorHandlerPlugin from "../plugins/error-handler";

// Routes
import candidateRoutes from "../routes/candidates";
import applicationRoutes from "../routes/applications";
import offerRoutes from "../routes/offers/offers.routes";
import commissionRoutes from "../routes/Commissions/commissions.routes";

// Admin API
import { authPlugin, authRoutes } from "@techia/admin-api";

export const buildApp = () => {
    const logger =
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
            : true;

    const app = Fastify({ logger });

    // ── Plugins (composition layer) ──
    app.register(errorHandlerPlugin);
    app.register(corsPlugin);
    app.register(databasePlugin);

    app.register(authPlugin, {
        secret: config.jwtSecret,
        accessTokenTtl: config.jwtAccessTokenTtl,
    });

    // ── Routes ──
    app.register(authRoutes, { prefix: "/api/auth" });
    app.register(candidateRoutes, { prefix: "/api/candidates" });
    app.register(applicationRoutes, { prefix: "/api/applications" });
    app.register(offerRoutes, { prefix: "/api/offers" });
    app.register(commissionRoutes, { prefix: "/api/commissions" });

    // ── Core routes ──
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