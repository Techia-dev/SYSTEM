import { Prisma, CandidateLevel } from "@prisma/client";
import { prisma } from "../../infra/prisma.client";
import {
    CreateCandidateDto,
    CreateCandidateResponse,
    ListCandidateResponse,
} from "@techia/types";

export class CandidatesService {
    async list(params: {
        page: number;
        pageSize: number;
        search?: string;
        level?: CandidateLevel;
    }): Promise<ListCandidateResponse> {
        const skip = (params.page - 1) * params.pageSize;

        const where: Prisma.CandidateWhereInput = {};

        if (params.search) {
            where.OR = [
                { name: { contains: params.search, mode: "insensitive" } },
                { email: { contains: params.search, mode: "insensitive" } },
                { phone: { contains: params.search } },
            ];
        }

        // ✅ NO ANY — strict enum check
        if (params.level) {
            where.level = params.level;
        }

        const [data, total] = await Promise.all([
            prisma.candidate.findMany({
                where,
                skip,
                take: params.pageSize,
                orderBy: { createdAt: "desc" },
            }),
            prisma.candidate.count({ where }),
        ]);

        return {
            data,
            total,
            page: params.page,
            pageSize: params.pageSize,
            totalPages: Math.ceil(total / params.pageSize),
        };
    }

    async create(
        input: CreateCandidateDto
    ): Promise<CreateCandidateResponse> {
        const candidate = await prisma.candidate.create({
            data: {
                name: input.name,
                phone: input.phone,
                email: input.email ?? null,

                // ✅ safe fallback without any casting
                level: input.level ?? CandidateLevel.junior,
            },
        });

        return {
            id: candidate.id,
            message: "Candidate created",
        };
    }
}