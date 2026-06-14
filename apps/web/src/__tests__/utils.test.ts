import { describe, it, expect } from "vitest";

function getErrorMessage(err: unknown): string {
    if (err instanceof Error) {
        return err.message;
    }
    return "An unexpected error occurred. Please try again.";
}

function formatCurrency(amount: number): string {
    return new Intl.NumberFormat("ar-EG", {
        style: "currency",
        currency: "EGP",
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    }).format(amount);
}

describe("Utility Functions", () => {
  describe("getErrorMessage", () => {
    it("should return message from Error instance", () => {
      expect(getErrorMessage(new Error("Something went wrong"))).toBe("Something went wrong");
    });

    it("should return default message for unknown errors", () => {
      expect(getErrorMessage(null)).toBe("An unexpected error occurred. Please try again.");
      expect(getErrorMessage(undefined)).toBe("An unexpected error occurred. Please try again.");
      expect(getErrorMessage("string")).toBe("An unexpected error occurred. Please try again.");
    });
  });

  describe("formatCurrency", () => {
    it("should format number as EGP currency", () => {
      const result = formatCurrency(15000);
      expect(result).toContain("15");
    });

    it("should handle zero", () => {
      const result = formatCurrency(0);
      expect(result).toContain("0");
    });
  });
});
