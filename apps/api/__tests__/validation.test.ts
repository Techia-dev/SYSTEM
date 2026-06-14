import { describe, it, expect } from "vitest";
import { z } from "zod";
import { validate } from "../src/shared/validation";

describe("Validation", () => {
  const schema = z.object({
    name: z.string().min(1, "Name is required"),
    email: z.string().email("Invalid email"),
    age: z.number().int().positive(),
  });

  it("should pass valid data", () => {
    const data = { name: "John", email: "john@test.com", age: 25 };
    const result = validate(schema, data);
    expect(result).toEqual(data);
  });

  it("should throw ValidationError for invalid data", () => {
    const data = { name: "", email: "invalid", age: -1 };

    try {
      validate(schema, data);
      expect.fail("Should have thrown");
    } catch (error: unknown) {
      const err = error as { statusCode: number; code: string; fields: Record<string, string[]> };
      expect(err.statusCode).toBe(400);
      expect(err.code).toBe("VALIDATION_ERROR");
      expect(err.fields).toBeDefined();
      expect(err.fields.name).toBeDefined();
      expect(err.fields.email).toBeDefined();
    }
  });
});
