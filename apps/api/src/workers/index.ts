/**
 * Worker Registration
 * Connects all event listeners to the event bus
 * Call this once on application startup
 */

import { eventBus } from "../shared/event-bus";
import { handleAuditLog } from "./audit-log.worker";
import { handleApplicationAccepted, handleApplicationRejected } from "./email.worker";
import {
    handleCandidateCreated,
    handleApplicationAccepted as handleApplicationAcceptedAnalytics,
    handleCommissionCreated,
} from "./analytics.worker";

/**
 * Register all event listeners
 * Call this in main.ts or server bootstrap
 */
export function registerWorkers(): void {
    // Register audit log listener for all events
    eventBus.on("CANDIDATE_CREATED", handleAuditLog);
    eventBus.on("APPLICATION_ACCEPTED", handleAuditLog);
    eventBus.on("APPLICATION_REJECTED", handleAuditLog);
    eventBus.on("COMMISSION_CREATED", handleAuditLog);

    // Register email listeners
    eventBus.on("APPLICATION_ACCEPTED", handleApplicationAccepted);
    eventBus.on("APPLICATION_REJECTED", handleApplicationRejected);

    // Register analytics listeners
    eventBus.on("CANDIDATE_CREATED", handleCandidateCreated);
    eventBus.on("APPLICATION_ACCEPTED", handleApplicationAcceptedAnalytics);
    eventBus.on("COMMISSION_CREATED", handleCommissionCreated);

    console.log("[Workers] All event listeners registered");
}
