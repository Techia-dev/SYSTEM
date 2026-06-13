import { CommissionsRepository } from "./commissions.repository";
import type {
    UpdateCommissionStatusDto,
    UpdateCommissionResponse,
    PaginatedResponse,
} from "@techia/types";
import type { Prisma, CommissionStatus } from "@prisma/client";
import { NotFoundError } from "../../shared/error";

export class CommissionsService {
    constructor(private readonly repository: CommissionsRepository) {}

    async list(params: {
        page: number;
        pageSize: number;
        status?: string;
    }): Promise<PaginatedResponse<unknown>> {
        const skip = (params.page - 1) * params.pageSize;

        const where: Prisma.CommissionWhereInput = {};
        if (params.status) {
            where.status = params.status as CommissionStatus;
        }

        const [commissions, total] = await Promise.all([
            this.repository.findMany({
                skip,
                take: params.pageSize,
                where,
                orderBy: { createdAt: "desc" },
                include: {
                    candidate: {
                        select: { id: true, name: true, phone: true },
                    },
                    offer: {
                        select: { id: true, title: true, company: true },
                    },
                },
            }),
            this.repository.count(where),
        ]);

        return {
            data: commissions,
            total,
            page: params.page,
            pageSize: params.pageSize,
            totalPages: Math.ceil(total / params.pageSize),
        };
    }

    async getById(id: string) {
        const commission = await this.repository.findUnique(id, {
            candidate: true,
            offer: true,
            application: {
                select: { id: true, status: true, source: true },
            },
        });

        if (!commission) {
            throw new NotFoundError("Commission", id);
        }

        return commission;
    }

    async updateStatus(
        id: string,
        input: UpdateCommissionStatusDto
    ): Promise<UpdateCommissionResponse> {
        const existing = await this.repository.findUnique(id);

        if (!existing) {
            throw new NotFoundError("Commission", id);
        }

        const { status } = input;

        const commission = await this.repository.update(id, {
            status,
        });

        return {
            id: commission.id,
            status: commission.status,
            message: `Commission marked as ${status}`,
        };
    }
}
