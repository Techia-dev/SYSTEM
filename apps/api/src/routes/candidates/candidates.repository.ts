import { Prisma } from "@prisma/client";
import { prisma } from "@techia/db";
import type { CandidateLevel } from "@techia/types";

export class CandidatesRepository {
    findMany(where: Prisma.CandidateWhereInput, skip: number, take: number) {
        return prisma.candidate.findMany({
            where,
            skip,
            take,
            orderBy: { createdAt: "desc" },
        });
    }

    count(where: Prisma.CandidateWhereInput) {
        return prisma.candidate.count({ where });
    }

    create(data: {
        name: string;
        phone: string;
        email?: string;
        level?: CandidateLevel;
    }) {
        return prisma.candidate.create({
            data: {
                ...data,
                level: data.level ?? "junior",
            },
        });
    }
}