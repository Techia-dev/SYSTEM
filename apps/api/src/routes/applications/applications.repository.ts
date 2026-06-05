import { prisma } from "@techia/db";
import type { ApplicationStatus } from "@techia/types";
import { NotFoundError } from "../../shared/error";

export class ApplicationsRepository {
    async findMany(skip: number, take: number) {
        return prisma.application.findMany({
            skip,
            take,
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

    async count(where?: { status?: string }) {
        return prisma.application.count();
    }

    /**
     * ATOMIC TRANSACTION: Update application status + create commission if accepted
     * This ensures both operations succeed or both fail
     */
    async updateStatusWithCommission(params: {
        id: string;
        status: ApplicationStatus;
    }) {
        return prisma.$transaction(async (tx) => {
            // Step 1: Update application status
            const application = await tx.application.update({
                where: { id: params.id },
                data: { status: params.status },
                include: {
                    offer: true,
                    candidate: true,
                },
            });

            // Step 2: If accepted, create commission
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