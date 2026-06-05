/**
 * Audit Log Worker
 * Listens to all domain events and creates audit log entries
 * Non-blocking async handler
 */

import type { DomainEvent } from "@techia/types";
import { auditLogService } from "../shared/audit-log.service";

export async function handleAuditLog(event: DomainEvent): Promise<void> {
    // Log the event asynchronously
    auditLogService.logEvent(event);
    
    // In production, you would:
    // - Write to database
    // - Send to external audit service
    // - Trigger compliance checks
    // All non-blocking
}
