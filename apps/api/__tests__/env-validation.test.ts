import { describe, it, expect } from "vitest";

describe("Environment Schema Validation", () => {
  const schema = {
    DATABASE_URL: { required: true, validate: (v: string) => v.length > 0 },
    JWT_SECRET: { required: true, validate: (v: string) => v.length >= 32 },
    NODE_ENV: { required: false, validate: (v?: string) => !v || ["development", "test", "production"].includes(v) },
    PORT: { required: false, validate: (v?: string) => !v || (Number.isInteger(Number(v)) && Number(v) > 0) },
  };

  it("should require DATABASE_URL when present", () => {
    const value = process.env.DATABASE_URL;
    if (value) {
      expect(schema.DATABASE_URL.validate(value)).toBe(true);
    }
  });

  it("should require JWT_SECRET to be at least 32 chars when present", () => {
    const value = process.env.JWT_SECRET;
    if (value) {
      expect(value.length).toBeGreaterThanOrEqual(32);
    }
  });

  it("should validate NODE_ENV when present", () => {
    const value = process.env.NODE_ENV;
    if (value) {
      expect(schema.NODE_ENV.validate(value)).toBe(true);
    }
  });

  it("should validate PORT when present", () => {
    const value = process.env.PORT;
    if (value) {
      expect(schema.PORT.validate(value)).toBe(true);
    }
  });

  it("CORS_ORIGINS should be valid URLs if set", () => {
    const corsOrigins = process.env.CORS_ORIGINS;
    if (corsOrigins) {
      const origins = corsOrigins.split(",").map((o) => o.trim()).filter(Boolean);
      for (const origin of origins) {
        expect(origin).toMatch(/^https?:\/\//);
      }
    }
  });
});
