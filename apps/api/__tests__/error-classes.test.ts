import { describe, it, expect } from "vitest";
import { AppError, ValidationError, NotFoundError, ConflictError, UnauthorizedError, ForbiddenError } from "../src/shared/error";

describe("Error Classes", () => {
  describe("AppError", () => {
    it("should create with message and status code", () => {
      const error = new AppError("Test error", 400, "TEST_ERROR");
      expect(error.message).toBe("Test error");
      expect(error.statusCode).toBe(400);
      expect(error.code).toBe("TEST_ERROR");
      expect(error.isOperational).toBe(true);
    });

    it("should default to 500", () => {
      const error = new AppError("Server error");
      expect(error.statusCode).toBe(500);
    });
  });

  describe("ValidationError", () => {
    it("should create with 400 status", () => {
      const error = new ValidationError("Invalid input", { name: ["Required"] });
      expect(error.statusCode).toBe(400);
      expect(error.code).toBe("VALIDATION_ERROR");
      expect(error.fields).toEqual({ name: ["Required"] });
    });
  });

  describe("NotFoundError", () => {
    it("should create with 404 status and resource name", () => {
      const error = new NotFoundError("Candidate", "123");
      expect(error.statusCode).toBe(404);
      expect(error.code).toBe("NOT_FOUND");
      expect(error.message).toContain("Candidate");
      expect(error.message).toContain("123");
    });
  });

  describe("ConflictError", () => {
    it("should create with 409 status", () => {
      const error = new ConflictError("Email already exists");
      expect(error.statusCode).toBe(409);
      expect(error.code).toBe("CONFLICT");
    });
  });

  describe("UnauthorizedError", () => {
    it("should create with 401 status", () => {
      const error = new UnauthorizedError();
      expect(error.statusCode).toBe(401);
      expect(error.code).toBe("UNAUTHORIZED");
    });
  });

  describe("ForbiddenError", () => {
    it("should create with 403 status", () => {
      const error = new ForbiddenError();
      expect(error.statusCode).toBe(403);
      expect(error.code).toBe("FORBIDDEN");
    });
  });
});
