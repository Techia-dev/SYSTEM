/**
 * Type-safe in-memory event bus for domain events
 * Supports async handlers without blocking main request flow
 */

export type DomainEvent = {
    eventType: string;
    timestamp: Date;
    aggregateId: string;
    [key: string]: unknown;
};

type EventHandler<T extends DomainEvent = DomainEvent> = (event: T) => Promise<void> | void;

class EventBus {
    private handlers: Map<string, Set<EventHandler>> = new Map();

    /**
     * Subscribe to an event type
     */
    on<T extends DomainEvent>(eventType: string, handler: EventHandler<T>): void {
        if (!this.handlers.has(eventType)) {
            this.handlers.set(eventType, new Set());
        }
        this.handlers.get(eventType)!.add(handler as EventHandler);
    }

    /**
     * Subscribe to an event type (alias for on)
     */
    subscribe<T extends DomainEvent>(eventType: string, handler: EventHandler<T>): void {
        this.on(eventType, handler);
    }

    /**
     * Unsubscribe from an event type
     */
    off(eventType: string, handler: EventHandler): void {
        this.handlers.get(eventType)?.delete(handler);
    }

    /**
     * Emit an event to all subscribed handlers
     * Handlers are executed asynchronously without blocking
     */
    async emit<T extends DomainEvent>(event: T): Promise<void> {
        const handlers = this.handlers.get(event.eventType);
        if (!handlers || handlers.size === 0) {
            return;
        }

        // Execute all handlers for this event type
        const promises = Array.from(handlers).map((handler) => {
            return Promise.resolve().then(() => handler(event)).catch((error) => {
                // Log handler errors but don't throw - handlers shouldn't crash main flow
                console.error(
                    `Error in handler for event ${event.eventType}:`,
                    error
                );
            });
        });

        // Await all handlers but use setImmediate to avoid blocking
        return new Promise((resolve) => {
            setImmediate(() => {
                Promise.all(promises).then(() => resolve()).catch(() => resolve());
            });
        });
    }

    /**
     * Get all subscribed handlers for an event type (for testing)
     */
    getHandlers(eventType: string): Set<EventHandler> | undefined {
        return this.handlers.get(eventType);
    }

    /**
     * Clear all handlers (for testing)
     */
    clear(): void {
        this.handlers.clear();
    }
}

// Singleton instance
export const eventBus = new EventBus();
