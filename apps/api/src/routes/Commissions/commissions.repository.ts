import { prisma } from "@techia/db";
import type { Prisma } from "@prisma/client";

export class CommissionsRepository {
    async findMany(params: {
        skip: number;
        take: number;
        where: Prisma.CommissionWhereInput;
        orderBy: Prisma.CommissionOrderByWithRelationInput;
        include?: Prisma.CommissionInclude;
    }) {
        return prisma.commission.findMany(params);
    }

    async count(where: Prisma.CommissionWhereInput) {
        return prisma.commission.count({ where });
    }

    async findUnique(id: string, include?: Prisma.CommissionInclude) {
        return prisma.commission.findUnique({
            where: { id },
            include,
        });
    }

    async update(id: string, data: Prisma.CommissionUpdateInput) {
        return prisma.commission.update({
            where: { id },
            data,
        });
    }
}
