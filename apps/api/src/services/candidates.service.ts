import { PrismaClient, CandidateLevel } from "@techia/db";

type ListParams = {
    page: number;
    pageSize: number;
    search?: string;
    level?: CandidateLevel;
};

type CreateParams = {
    name: string;
    phone: string;
    email?: string;
    level?: CandidateLevel;
};

export class CandidatesService {
    constructor(private prisma: PrismaClient) { }

    async list(params: ListParams) {
        const { page, pageSize, search, level } = params;

        const skip = (page - 1) * pageSize;

        const where: Prisma.CandidateWhereInput = {};

        if (search) {
            where.OR = [
                { name: { contains: search, mode: "insensitive" } },
                { email: { contains: search, mode: "insensitive" } },
                { phone: { contains: search } },
            ];
        }

        if (level) {
            where.level = level;
        }

        const [data, total] = await Promise.all([
            this.prisma.candidate.findMany({
                where,
                orderBy: { createdAt: "desc" },
                skip,
                take: pageSize,
            }),
            this.prisma.candidate.count({ where }),
        ]);

        return {
            data,
            total,
            page,
            pageSize,
            totalPages: Math.ceil(total / pageSize),
        };
    }

    async create(input: CreateParams) {
        const candidate = await this.prisma.candidate.create({
            data: {
                name: input.name,
                phone: input.phone,
                email: input.email ?? null,
                level: input.level ?? "junior",
            },
        });

        return {
            id: candidate.id,
            message: "Candidate created",
        };
    }
}