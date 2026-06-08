import { prisma } from "@techia/db";
import type { Prisma } from "@prisma/client";
import type { ApplicationStatus } from "@techia/types";

export class ApplicationsRepository {
    async findMany(skip: number, take: number, where?: Prisma.ApplicationWhereInput) {
        return prisma.application.findMany({
            skip,
            take,
            where,
            include: {
                candidate: true,
                offer: true,
            },
            orderBy: { createdAt: "desc" },
        });
    }

    async findById(id: string) {
        return prisma.application.findUnique({
            where: { id },
            include: {
                candidate: true,
                offer: true,
                commission: true,
            },
        });
    }

    async count(where?: Prisma.ApplicationWhereInput): Promise<number> {
        return prisma.application.count({ where });
    }

    async existsByCandidateAndOffer(candidateId: string, offerId: string): Promise<boolean> {
        const count = await prisma.application.count({
            where: { candidateId, offerId },
        });
        return count > 0;
    }

    async create(data: {
        candidateId: string;
        offerId: string;
        source?: string;
        assignedTo?: string;
        status?: ApplicationStatus;
    }) {
        return prisma.application.create({
            data: {
                candidateId: data.candidateId,
                offerId: data.offerId,
                source: data.source ?? null,
                assignedTo: data.assignedTo ?? null,
                status: data.status ?? "applied",
            },
            include: {
                candidate: true,
                offer: true,
            },
        });
    }

    async findCommissionByApplicationId(applicationId: string) {
        return prisma.commission.findUnique({
            where: { applicationId },
        });
    }

    async delete(id: string) {
        return prisma.application.delete({ where: { id } });
    }

    async updateStatusWithCommission(params: {
        id: string;
        status: ApplicationStatus;
    }) {
        return prisma.$transaction(async (tx) => {
            const application = await tx.application.update({
                where: { id: params.id },
                data: { status: params.status },
                include: {
                    offer: true,
                    candidate: true,
                },
            });

            if (params.status === "accepted") {
                const dueDate = new Date();
                dueDate.setDate(dueDate.getDate() + (application.offer?.commissionDelay || 0));

                await tx.commission.create({
                    data: {
                        applicationId: application.id,
                        offerId: application.offerId,
                        candidateId: application.candidateId,
                        amount: application.offer?.commission || 0,
                        status: "pending",
                        dueDate,
                    },
                });
            }

            return application;
        });
    }
}