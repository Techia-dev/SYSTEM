/**
 * Audit Log Service
 * Tracks all important domain events for compliance and debugging
 * Triggered by event bus, not called directly from services
 */

import type { DomainEvent } from "@techia/types";

export type AuditLogEntry = {
    id: string;
    eventType: string;
    entity: string;
    action: string;
    entityId: string;
    aggregateId: string;
    before?: unknown;
    after?: unknown;
    userId?: string;
    timestamp: Date;
    metadata?: Record<string, unknown>;
};

class AuditLogService {
    // In-memory store for audit logs (replace with DB persistence in production)
    private logs: AuditLogEntry[] = [];
    private idCounter = 0;

    /**
     * Log an event from domain event system
     */
    logEvent(event: DomainEvent): AuditLogEntry {
        const entry: AuditLogEntry = {
            id: `audit_${++this.idCounter}`,
            eventType: event.eventType,
            entity: this.extractEntity(event.eventType),
            action: this.extractAction(event.eventType),
            entityId: event.aggregateId,
            aggregateId: event.aggregateId,
            timestamp: event.timestamp,
            metadata: this.extractMetadata(event),
        };

        this.logs.push(entry);
        return entry;
    }

    /**
     * Get all audit logs (for development/testing)
     */
    getLogs(): AuditLogEntry[] {
        return [...this.logs];
    }

    /**
     * Get audit logs for a specific entity
     */
    getLogsForEntity(entityId: string): AuditLogEntry[] {
        return this.logs.filter((log) => log.entityId === entityId);
    }

    /**
     * Clear all logs (for testing)
     */
    clear(): void {
        this.logs = [];
        this.idCounter = 0;
    }

    private extractEntity(eventType: string): string {
        if (eventType.includes("CANDIDATE")) return "candidate";
        if (eventType.includes("APPLICATION")) return "application";
        if (eventType.includes("COMMISSION")) return "commission";
        if (eventType.includes("OFFER")) return "offer";
        return "unknown";
    }

    private extractAction(eventType: string): string {
        if (eventType.includes("CREATED")) return "created";
        if (eventType.includes("ACCEPTED")) return "accepted";
        if (eventType.includes("REJECTED")) return "rejected";
        if (eventType.includes("UPDATED")) return "updated";
        return "modified";
    }

    private extractMetadata(event: DomainEvent): Record<string, unknown> {
        // eslint-disable-next-line @typescript-eslint/no-unused-vars
        const { eventType, timestamp, aggregateId, ...rest } = event;
        return rest;
    }
}

// Singleton instance
export const auditLogService = new AuditLogService();
