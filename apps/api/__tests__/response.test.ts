import { describe, it, expect } from "vitest";
import { successResponse, errorResponse } from "../src/shared/response";

describe("Response Helpers", () => {
  describe("successResponse", () => {
    it("should wrap data with success: true", () => {
      const result = successResponse({ id: "1", name: "Test" });
      expect(result.success).toBe(true);
      expect(result.data).toEqual({ id: "1", name: "Test" });
    });

    it("should include meta when provided", () => {
      const result = successResponse([], { total: 10, page: 1 });
      expect(result.success).toBe(true);
      expect(result.meta).toEqual({ total: 10, page: 1 });
    });
  });

  describe("errorResponse", () => {
    it("should return error response with message and code", () => {
      const result = errorResponse("Not found", "NOT_FOUND");
      expect(result.success).toBe(false);
      expect(result.error.message).toBe("Not found");
      expect(result.error.code).toBe("NOT_FOUND");
    });

    it("should include fields when provided", () => {
      const result = errorResponse("Validation failed", "VALIDATION_ERROR", { email: ["Invalid format"] });
      expect(result.success).toBe(false);
      expect(result.error.fields).toEqual({ email: ["Invalid format"] });
    });
  });
});
