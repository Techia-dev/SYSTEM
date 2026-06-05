import { prisma } from "@techia/db";
import type { Prisma } from "@prisma/client";

export class OffersRepository {
    async findMany(params: {
        skip: number;
        take: number;
        orderBy: Prisma.OfferOrderByWithRelationInput;
    }) {
        return prisma.offer.findMany(params);
    }

    async count() {
        return prisma.offer.count();
    }

    async findUnique(id: string, include?: Prisma.OfferInclude) {
        return prisma.offer.findUnique({
            where: { id },
            include,
        });
    }

    async create(data: Prisma.OfferCreateInput) {
        return prisma.offer.create({ data });
    }

    async update(id: string, data: Prisma.OfferUpdateInput) {
        return prisma.offer.update({
            where: { id },
            data,
        });
    }
}
