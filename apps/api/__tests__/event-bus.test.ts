import { describe, it, expect, beforeEach } from "vitest";
import { eventBus } from "../src/shared/event-bus";

describe("EventBus", () => {
  beforeEach(() => {
    eventBus.clear();
  });

  it("should register and emit events", async () => {
    let called = false;
    eventBus.on("TEST_EVENT", () => {
      called = true;
    });

    await eventBus.emit({ eventType: "TEST_EVENT", timestamp: new Date(), aggregateId: "1" });
    expect(called).toBe(true);
  });

  it("should pass event data to handlers", async () => {
    let receivedData: Record<string, unknown> | null = null;
    eventBus.on("DATA_EVENT", (event) => {
      receivedData = event;
    });

    const event = { eventType: "DATA_EVENT", timestamp: new Date(), aggregateId: "1", name: "test", value: 42 };
    await eventBus.emit(event);
    expect(receivedData).not.toBeNull();
    expect(receivedData.name).toBe("test");
    expect(receivedData.value).toBe(42);
  });

  it("should support multiple handlers per event", async () => {
    let count = 0;
    eventBus.on("MULTI", () => { count++; });
    eventBus.on("MULTI", () => { count++; });

    await eventBus.emit({ eventType: "MULTI", timestamp: new Date(), aggregateId: "1" });
    expect(count).toBe(2);
  });

  it("should unregister handlers", async () => {
    let count = 0;
    const handler = () => { count++; };
    eventBus.on("UNREGISTER", handler);
    eventBus.off("UNREGISTER", handler);

    await eventBus.emit({ eventType: "UNREGISTER", timestamp: new Date(), aggregateId: "1" });
    expect(count).toBe(0);
  });

  it("should handle errors in handlers gracefully", async () => {
    eventBus.on("ERROR_EVENT", () => {
      throw new Error("Handler error");
    });

    let secondCalled = false;
    eventBus.on("ERROR_EVENT", () => {
      secondCalled = true;
    });

    await eventBus.emit({ eventType: "ERROR_EVENT", timestamp: new Date(), aggregateId: "1" });
    expect(secondCalled).toBe(true);
  });

  it("should clear all handlers", () => {
    eventBus.on("A", () => {});
    eventBus.on("B", () => {});
    eventBus.clear();

    expect(eventBus.getHandlers("A")).toBeUndefined();
    expect(eventBus.getHandlers("B")).toBeUndefined();
  });
});
