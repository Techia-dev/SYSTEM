import { Prisma, CandidateLevel as PrismaCandidateLevel } from "@prisma/client";
import { prisma } from "@techia/db";
import type { CandidateLevel } from "@techia/types";

type CreateData = {
    name: string;
    phone: string;
    secondaryPhone?: string;
    email?: string;
    level?: string;
    qualification?: string;
    experience?: string;
};

type UpdateData = {
    name?: string;
    phone?: string;
    secondaryPhone?: string | null;
    email?: string | null;
    level?: CandidateLevel;
    qualification?: string | null;
    experience?: string | null;
    cvUrl?: string | null;
};

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

    findById(id: string) {
        return prisma.candidate.findUnique({ where: { id } });
    }

    create(data: CreateData) {
        return prisma.candidate.create({
            data: {
                name: data.name,
                phone: data.phone,
                secondaryPhone: data.secondaryPhone ?? null,
                email: data.email ?? null,
                level: (data.level ?? "junior") as PrismaCandidateLevel,
                qualification: data.qualification ?? null,
                experience: data.experience ?? null,
            },
        });
    }

    update(id: string, data: UpdateData) {
        return prisma.candidate.update({
            where: { id },
            data: data as Prisma.CandidateUpdateInput,
        });
    }

    delete(id: string) {
        return prisma.candidate.delete({ where: { id } });
    }
}
