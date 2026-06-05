import { Prisma, CandidateLevel } from "@prisma/client";
import type { ListCandidatesResponse, CreateCandidateDto, CandidateCreatedEvent } from "@techia/types";
import type { CandidatesRepository } from "./candidates.repository";
import { ValidationError, ConflictError } from "../../shared/error";
import { eventBus } from "../../shared/event-bus";

export class CandidatesService {
    constructor(private readonly repository: CandidatesRepository) { }

    async list(params: {
        page: number;
        pageSize: number;
        search?: string;
        level?: CandidateLevel;
    }): Promise<ListCandidatesResponse> {
        const skip = (params.page - 1) * params.pageSize;

        const where: Prisma.CandidateWhereInput = {};

        if (params.search) {
            where.OR = [
                { name: { contains: params.search, mode: "insensitive" } },
                { email: { contains: params.search, mode: "insensitive" } },
                { phone: { contains: params.search } },
            ];
        }

        if (params.level) {
            where.level = params.level;
        }

        const [data, total] = await Promise.all([
            this.repository.findMany(where, skip, params.pageSize),
            this.repository.count(where),
        ]);

        return {
            data: data.map(candidate => ({
                ...candidate,
                createdAt: candidate.createdAt.toISOString(),
                updatedAt: candidate.updatedAt.toISOString(),
            })),
            total,
            page: params.page,
            pageSize: params.pageSize,
            totalPages: Math.ceil(total / params.pageSize),
        };
    }

    async create(input: CreateCandidateDto) {
        try {
            const candidate = await this.repository.create(input);

            // Emit domain event AFTER successful creation (non-blocking)
            const event: CandidateCreatedEvent = {
                eventType: "CANDIDATE_CREATED",
                timestamp: new Date(),
                aggregateId: candidate.id,
                candidateId: candidate.id,
                name: candidate.name,
                email: candidate.email || undefined,
                phone: candidate.phone,
                level: candidate.level,
            };
            eventBus.emit(event).catch((error) => {
                console.error("Error emitting CANDIDATE_CREATED event:", error);
            });

            return {
                id: candidate.id,
                message: "Candidate created",
            };
        } catch (error) {
            if (error instanceof Prisma.PrismaClientKnownRequestError) {
                if (error.code === "P2002") {
                    const target = (error.meta?.target as string[] | undefined)?.[0];
                    throw new ConflictError(`Candidate with this ${target || "field"} already exists`);
                }
            }
            throw error;
        }
    }
}