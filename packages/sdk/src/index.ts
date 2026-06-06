/**
 * Techia SDK
 * Type-safe API client for Techia ATS system
 */

export { TechiaSdk } from "./sdk";
export { HttpClient, TechiaSdkError } from "./client";
export type { ClientConfig, ApiResponse } from "./client";

export { CandidatesResource } from "./modules/candidates";
export { ApplicationsResource } from "./modules/applications";
export { OffersResource } from "./modules/offers";
export { CommissionsResource } from "./modules/commissions";

// Re-export types from @techia/types
export type {
    DomainEvent,
    CandidateCreatedEvent,
    ApplicationAcceptedEvent,
    ApplicationRejectedEvent,
    CommissionCreatedEvent,
} from "@techia/types";

export type {
    Candidate,
    CreateCandidateDto,
    ListCandidatesResponse,
} from "@techia/types";

export type {
    Application,
    CreateApplicationDto,
    UpdateApplicationStatusDto,
    UpdateStatusResponse,
} from "@techia/types";

export type {
    Offer,
    CreateOfferDto,
    UpdateOfferDto,
} from "@techia/types";

export type {
    Commission,
    UpdateCommissionStatusDto,
    UpdateCommissionResponse,
} from "@techia/types";

export type {
    ApplicationStatus,
    CommissionStatus,
    CandidateLevel,
} from "@techia/types";
