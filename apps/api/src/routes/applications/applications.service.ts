import type { Prisma } from "@prisma/client";
import { ApplicationStatus } from "@prisma/client";
import type {
    UpdateStatusResponse,
    CreateApplicationDto,
    UpdateApplicationStatusDto,
    CreateApplicationResponse,
    ApplicationAcceptedEvent,
    ApplicationRejectedEvent,
    CommissionCreatedEvent,
} from "@techia/types";
import type { ApplicationsRepository } from "./applications.repository";
import { prisma } from "@techia/db";
import { NotFoundError, ConflictError, ValidationError } from "../../shared/error";
import { eventBus } from "../../shared/event-bus";

export class ApplicationsService {
    constructor(private readonly repository: ApplicationsRepository) { }

    async list(params: {
        page: number;
        pageSize: number;
        status?: string;
    }) {
        const skip = (params.page - 1) * params.pageSize;

        const where: Prisma.ApplicationWhereInput | undefined = params.status ? { status: params.status as ApplicationStatus } : undefined;

        const [applications, total] = await Promise.all([
            this.repository.findMany(skip, params.pageSize, where),
            this.repository.count(where),
        ]);

        return {
            data: applications,
            total,
            page: params.page,
            pageSize: params.pageSize,
            totalPages: Math.ceil(total / params.pageSize),
        };
    }

    async getById(id: string) {
        const application = await this.repository.findById(id);

        if (!application) {
            throw new NotFoundError("Application", id);
        }

        return application;
    }

    async create(input: CreateApplicationDto): Promise<CreateApplicationResponse> {
        const { candidateId, offerId } = input;

        const [candidate, offer] = await Promise.all([
            prisma.candidate.findUnique({ where: { id: candidateId } }),
            prisma.offer.findUnique({ where: { id: offerId } }),
        ]);

        if (!candidate) {
            throw new NotFoundError("Candidate", candidateId);
        }

        if (!offer) {
            throw new NotFoundError("Offer", offerId);
        }

        if (!offer.isActive) {
            throw new ValidationError("Offer is no longer active");
        }

        const duplicate = await this.repository.existsByCandidateAndOffer(candidateId, offerId);
        if (duplicate) {
            throw new ConflictError("An application already exists for this candidate and offer");
        }

        const application = await this.repository.create(input);

        return {
            id: application.id,
            message: "Application created",
        };
    }

    async updateStatus(id: string, data: UpdateApplicationStatusDto): Promise<UpdateStatusResponse> {
        const application = await this.repository.findById(id);

        if (!application) {
            throw new NotFoundError("Application", id);
        }

        await this.repository.updateStatusWithCommission({
            id,
            status: data.status,
        });

        this.emitStatusChangeEvent(id, data.status, application.candidateId, application.offerId);

        if (data.status === "accepted") {
            const commission = await this.repository.findCommissionByApplicationId(id);
            if (commission) {
                const event: CommissionCreatedEvent = {
                    eventType: "COMMISSION_CREATED",
                    timestamp: new Date(),
                    aggregateId: commission.id,
                    commissionId: commission.id,
                    applicationId: id,
                    candidateId: application.candidateId,
                    offerId: application.offerId,
                    amount: commission.amount,
                    dueDate: commission.dueDate,
                };
                eventBus.emit(event).catch((error) => {
                    console.error("Error emitting COMMISSION_CREATED event:", error);
                });
            }
        }

        return {
            success: true,
            message: `Application status updated to ${data.status}`,
        };
    }

    async delete(id: string) {
        const application = await this.repository.findById(id);
        if (!application) {
            throw new NotFoundError("Application", id);
        }
        const commission = await this.repository.findCommissionByApplicationId(id);
        if (commission) {
            await prisma.commission.delete({ where: { id: commission.id } });
        }
        await this.repository.delete(id);
        return { message: "Application deleted" };
    }

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