import Fastify from "fastify";
import cors from "@fastify/cors";
import helmet from "@fastify/helmet";
import rateLimit from "@fastify/rate-limit";
import multipart from "@fastify/multipart";
import { config } from "../config";

// Plugins
import prismaPlugin from "../plugins/prisma.plugin";
import { authPlugin } from "@techia/admin-api";

// Routes
import candidateRoutes from "../routes/candidates/candidates.routes";
import applicationRoutes from "../routes/applications";
import offerRoutes from "../routes/offers/offers.routes";
import commissionRoutes from "../routes/commissions/commissions.routes";
import dashboardRoutes from "../routes/dashboard/dashboard.routes";
import { authRoutes } from "@techia/admin-api";

// Shared
import { AppError, ValidationError, ConflictError, NotFoundError } from "../shared/error";
import { errorResponse } from "../shared/response";
import { Prisma } from "@prisma/client";
import bcryptjs from "bcryptjs";

// Workers
import { registerWorkers } from "../workers";

const allowedOrigins = config.corsOrigins.length > 0
    ? config.corsOrigins
    : ["http://localhost:3000"];

const corsOriginHandler = (
    origin: string | undefined,
    cb: (err: Error | null, allow: boolean) => void
): void => {
    if (!origin) return cb(null, true);
    if (allowedOrigins.includes(origin)) return cb(null, true);

    try {
        const url = new URL(origin);
        const hostname = url.hostname;

        if (hostname.endsWith(".vercel.app")) return cb(null, true);
        if (hostname.endsWith(".railway.app")) return cb(null, true);
        if (hostname === "localhost" || hostname.startsWith("localhost.")) return cb(null, true);
    } catch {
        // Invalid URL origin - deny
    }

    cb(new Error(`CORS: origin ${origin} not allowed`), false);
};

export const buildApp = () => {
    const app = Fastify({
        logger: config.nodeEnv === "production"
            ? { level: config.logLevel }
            : {
                transport: {
                    target: "pino-pretty",
                    options: {
                        translateTime: "HH:MM:ss",
                        ignore: "pid,hostname",
                        colorize: true,
                    },
                },
            },
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

        if (error instanceof Prisma.PrismaClientKnownRequestError) {
            if (error.code === "P2003") {
                return reply.status(409).send(
                    errorResponse("Cannot delete: record has related data", "CONFLICT")
                );
            }
            if (error.code === "P2025") {
                return reply.status(404).send(
                    errorResponse("Record not found", "NOT_FOUND")
                );
            }
            if (error.code === "P2002") {
                return reply.status(409).send(
                    errorResponse("Record already exists", "CONFLICT")
                );
            }
            return reply.status(400).send(
                errorResponse(`Database error: ${error.message}`, "DB_ERROR")
            );
        }

        if (error instanceof Prisma.PrismaClientValidationError) {
            return reply.status(400).send(
                errorResponse("Invalid data provided", "VALIDATION_ERROR")
            );
        }

        const message = error instanceof Error ? error.message : "Internal Server Error";
        reply.status(500).send(errorResponse(message, "UNKNOWN_ERROR"));
    });

    // ============================================================
    // SECURITY HEADERS
    // ============================================================

    app.register(helmet, {
        crossOriginResourcePolicy: { policy: "cross-origin" },
        crossOriginOpenerPolicy: { policy: "unsafe-none" },
    });

    // ============================================================
    // PRISMA (shared by healthcheck + API routes)
    // ============================================================

    app.register(prismaPlugin);

    // ============================================================
    // CORS (at root level so healthcheck + API both get it)
    // ============================================================

    app.register(cors, {
        origin: corsOriginHandler,
        credentials: true,
        methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
        exposedHeaders: ["Authorization"],
        preflightContinue: false,
        optionsSuccessStatus: 204,
    });

    // ============================================================
    // HEALTHCHECK
    // ============================================================

    app.get("/health", async () => ({
        status: "ok",
        env: config.nodeEnv,
        timestamp: new Date().toISOString(),
    }));

    app.get("/health/ready", async (request, reply) => {
        try {
            const prisma = request.server.prisma;
            await prisma.$queryRaw`SELECT 1`;
            return {
                status: "ok",
                database: "connected",
                env: config.nodeEnv,
                timestamp: new Date().toISOString(),
            };
        } catch {
            return reply.status(503).send({
                status: "error",
                database: "disconnected",
                env: config.nodeEnv,
                timestamp: new Date().toISOString(),
            });
        }
    });

    // ============================================================
    // SETUP (one-time admin creation — no auth required)
    // ============================================================

    app.post<{
        Body: { email: string; password: string; name?: string };
    }>("/api/setup", async (request, reply) => {
        const { email, password, name } = request.body;

        if (!email || !password || password.length < 6) {
            return reply.status(400).send({ success: false, error: "Email and password (min 6 chars) required" });
        }

        const hash = await bcryptjs.hash(password, 12);

        const existing = await request.server.prisma.user.findUnique({ where: { email } });
        if (existing) {
            await request.server.prisma.user.update({
                where: { email },
                data: { password: hash, name: name ?? "Admin", role: "admin" },
            });
            return reply.status(200).send({ success: true, message: "Admin user password updated", userId: existing.id });
        }

        const user = await request.server.prisma.user.create({
            data: { email, password: hash, name: name ?? "Admin", role: "admin" },
        });

        return reply.status(201).send({ success: true, message: "Admin user created", userId: user.id });
    });

    // ============================================================
    // WORKERS
    // ============================================================

    registerWorkers();

    // ============================================================
    // API (rate-limit → auth → routes)
    // ============================================================

    app.register(async (apiApp) => {

        apiApp.register(multipart, {
            limits: {
                fileSize: 10 * 1024 * 1024, // 10 MB
                files: 1,
            },
        });

        apiApp.register(rateLimit, {
            global: true,
            max: 100,
            timeWindow: "1 minute",
        });

        apiApp.register(authPlugin, {
            secret: config.jwtSecret,
            accessTokenTtl: config.jwtAccessTokenTtl,
        });

        // ── Routes ────────────────────────────────────────────
        apiApp.register(authRoutes, { prefix: "/api/auth" });
        apiApp.register(candidateRoutes, { prefix: "/api/candidates" });
        apiApp.register(applicationRoutes, { prefix: "/api/applications" });
        apiApp.register(offerRoutes, { prefix: "/api/offers" });
        apiApp.register(commissionRoutes, { prefix: "/api/commissions" });
        apiApp.register(dashboardRoutes, { prefix: "/api/dashboard" });

        apiApp.get("/", async () => ({
            message: "ATS API Running",
        }));
    });

    return app;
};
