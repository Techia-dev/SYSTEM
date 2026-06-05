/**
 * Domain Event Types - Strongly typed events for the system
 * All events follow the DomainEvent interface pattern
 */

export type DomainEventBase = {
    eventType: string;
    timestamp: Date;
    aggregateId: string;
};

/**
 * Emitted when a candidate is created
 */
export type CandidateCreatedEvent = DomainEventBase & {
    eventType: "CANDIDATE_CREATED";
    candidateId: string;
    name: string;
    email?: string;
    phone: string;
    level: string;
};

/**
 * Emitted when an application status changes to "accepted"
 */
export type ApplicationAcceptedEvent = DomainEventBase & {
    eventType: "APPLICATION_ACCEPTED";
    applicationId: string;
    candidateId: string;
    offerId: string;
};

/**
 * Emitted when an application status changes to "rejected"
 */
export type ApplicationRejectedEvent = DomainEventBase & {
    eventType: "APPLICATION_REJECTED";
    applicationId: string;
    candidateId: string;
    offerId: string;
    reason?: string;
};

/**
 * Emitted when a commission is created
 */
export type CommissionCreatedEvent = DomainEventBase & {
    eventType: "COMMISSION_CREATED";
    commissionId: string;
    applicationId: string;
    candidateId: string;
    offerId: string;
    amount: number;
    dueDate: Date;
};

// Union type for all domain events
export type DomainEvent =
    | CandidateCreatedEvent
    | ApplicationAcceptedEvent
    | ApplicationRejectedEvent
    | CommissionCreatedEvent;
