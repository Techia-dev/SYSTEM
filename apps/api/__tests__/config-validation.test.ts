import { describe, it, expect } from "vitest";
import { z } from "zod";

describe("Config Schema Validation", () => {
  const envSchema = z.object({
    NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
    PORT: z.coerce.number().int().positive().default(4000),
    HOST: z.string().min(1).default("0.0.0.0"),
    DATABASE_URL: z.string().min(1),
    JWT_SECRET: z.string().min(32),
    JWT_ACCESS_TOKEN_TTL: z.string().default("15m"),
    LOG_LEVEL: z.enum(["trace", "debug", "info", "warn", "error", "fatal"]).default("info"),
    CORS_ORIGINS: z.string().optional(),
  });

  it("should accept valid production config", () => {
    const env = {
      NODE_ENV: "production",
      PORT: "4000",
      HOST: "0.0.0.0",
      DATABASE_URL: "postgresql://user:pass@localhost:5432/db",
      JWT_SECRET: "a".repeat(32),
      JWT_ACCESS_TOKEN_TTL: "15m",
      LOG_LEVEL: "info",
    };
    const result = envSchema.parse(env);
    expect(result.NODE_ENV).toBe("production");
    expect(result.PORT).toBe(4000);
  });

  it("should reject short JWT_SECRET", () => {
    const env = {
      DATABASE_URL: "postgresql://user:pass@localhost:5432/db",
      JWT_SECRET: "short",
    };
    expect(() => envSchema.parse(env)).toThrow();
  });

  it("should reject missing DATABASE_URL", () => {
    const env = {
      JWT_SECRET: "a".repeat(32),
    };
    expect(() => envSchema.parse(env)).toThrow();
  });

  it("should apply defaults", () => {
    const env = {
      DATABASE_URL: "postgresql://user:pass@localhost:5432/db",
      JWT_SECRET: "a".repeat(32),
    };
    const result = envSchema.parse(env);
    expect(result.NODE_ENV).toBe("development");
    expect(result.PORT).toBe(4000);
    expect(result.HOST).toBe("0.0.0.0");
    expect(result.LOG_LEVEL).toBe("info");
  });
});
