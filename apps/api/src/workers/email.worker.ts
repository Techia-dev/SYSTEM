/**
 * Email Worker
 * Listens to application events and sends email notifications
 * Simulated async handler - non-blocking
 */

import type { ApplicationAcceptedEvent, ApplicationRejectedEvent } from "@techia/types";

/**
 * Send acceptance notification email
 */
export async function handleApplicationAccepted(
    event: ApplicationAcceptedEvent
): Promise<void> {
    // Simulate async email sending
    return new Promise((resolve) => {
        setTimeout(() => {
            console.log(
                `[EMAIL WORKER] Sent acceptance notification to candidate ${event.candidateId}`
            );
            // In production:
            // - Send via SendGrid, AWS SES, etc.
            // - Track delivery
            // - Implement retries
            resolve();
        }, 100);
    });
}

/**
 * Send rejection notification email
 */
export async function handleApplicationRejected(
    event: ApplicationRejectedEvent
): Promise<void> {
    // Simulate async email sending
    return new Promise((resolve) => {
        setTimeout(() => {
            console.log(
                `[EMAIL WORKER] Sent rejection notification to candidate ${event.candidateId} (reason: ${event.reason || "unspecified"})`
            );
            // In production:
            // - Send via SendGrid, AWS SES, etc.
            // - Log rejection
            // - Provide feedback
            resolve();
        }, 100);
    });
}
