import type {
    UpdateStatusResponse,
    CreateApplicationDto,
    UpdateApplicationStatusDto,
    CreateApplicationResponse,
    ApplicationAcceptedEvent,
    ApplicationRejectedEvent,
} from "@techia/types";
import type { ApplicationsRepository } from "./applications.repository";
import { NotFoundError, ValidationError, ConflictError } from "../../shared/error";
import { eventBus } from "../../shared/event-bus";

export class ApplicationsService {
    constructor(private readonly repository: ApplicationsRepository) { }

    async list(params: {
        page: number;
        pageSize: number;
        status?: string;
    }) {
        const skip = (params.page - 1) * params.pageSize;

        const applications = await this.repository.findMany(skip, params.pageSize);

        return {
            data: applications,
            page: params.page,
            pageSize: params.pageSize,
        };
    }

    async getById(id: string) {
        const application = await this.repository.findById(id);

        if (!application) {
            throw new NotFoundError("Application", id);
        }

        return application;
    }

    async create(_input: CreateApplicationDto): Promise<CreateApplicationResponse> {
        // TODO: implement create logic with proper validations
        return {
            id: "temp-id",
            message: "Application created",
        };
    }

    /**
     * Update application status atomically
     * If status changes to "accepted", commission is created in the same transaction
     * Emits domain events after successful transaction
     */
    async updateStatus(id: string, data: UpdateApplicationStatusDto): Promise<UpdateStatusResponse> {
        const application = await this.repository.findById(id);

        if (!application) {
            throw new NotFoundError("Application", id);
        }

        // Use atomic transaction for status update + commission creation
        await this.repository.updateStatusWithCommission({
            id,
            status: data.status,
        });

        // Emit domain event AFTER transaction succeeds (non-blocking)
        this.emitStatusChangeEvent(id, data.status, application.candidateId, application.offerId);

        return {
            success: true,
            message: `Application status updated to ${data.status}`,
        };
    }

    /**
     * Emit status change event
     * Non-blocking - emitted after response sent
     */
    private emitStatusChangeEvent(
        applicationId: string,
        status: string,
        candidateId: string,
        offerId: string
    ): void {
        if (status === "accepted") {
            const event: ApplicationAcceptedEvent = {
                eventType: "APPLICATION_ACCEPTED",
                timestamp: new Date(),
                aggregateId: applicationId,
                applicationId,
                candidateId,
                offerId,
            };
            eventBus.emit(event).catch((error) => {
                console.error("Error emitting APPLICATION_ACCEPTED event:", error);
            });
        } else if (status === "rejected") {
            const event: ApplicationRejectedEvent = {
                eventType: "APPLICATION_REJECTED",
                timestamp: new Date(),
                aggregateId: applicationId,
                applicationId,
                candidateId,
                offerId,
            };
            eventBus.emit(event).catch((error) => {
                console.error("Error emitting APPLICATION_REJECTED event:", error);
            });
        }
    }
}