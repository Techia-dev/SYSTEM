import "dotenv/config";
import { z } from "zod";

const envSchema = z.object({
    NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
    PORT: z.coerce.number().int().positive().default(4000),
    HOST: z.string().min(1).default("0.0.0.0"),
    DATABASE_URL: z.string().min(1),
    JWT_SECRET: z.string().min(32),
    JWT_ACCESS_TOKEN_TTL: z.string().default("15m"),
    LOG_LEVEL: z.enum(["trace", "debug", "info", "warn", "error", "fatal"]).default("info"),
    CORS_ORIGIN: z.string().optional(),
    CORS_ORIGINS: z.string().optional(),
});

const env = envSchema.parse(process.env);

const corsOriginsRaw = env.CORS_ORIGINS ?? env.CORS_ORIGIN ?? "";

export const config = {
    port: env.PORT,
    host: env.HOST,
    nodeEnv: env.NODE_ENV,
    databaseUrl: env.DATABASE_URL,
    jwtSecret: env.JWT_SECRET,
    jwtAccessTokenTtl: env.JWT_ACCESS_TOKEN_TTL,
    logLevel: env.LOG_LEVEL,
    corsOrigins: corsOriginsRaw
        .split(",")
        .map((o) => o.trim())
        .filter(Boolean),
};