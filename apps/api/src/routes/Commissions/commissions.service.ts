import { CommissionsRepository } from "./commissions.repository";
import type {
    UpdateCommissionStatusDto,
    UpdateCommissionResponse,
    PaginatedResponse,
} from "@techia/types";

export class CommissionsService {
    constructor(private readonly repository: CommissionsRepository) {}

    async list(params: {
        page: number;
        pageSize: number;
        status?: string;
    }): Promise<PaginatedResponse<unknown>> {
        const skip = (params.page - 1) * params.pageSize;

        const where: Record<string, unknown> = {};
        if (params.status) {
            where.status = params.status;
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
            page_size: params.pageSize,
            total_pages: Math.ceil(total / params.pageSize),
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

        return commission;
    }

    async updateStatus(
        id: string,
        input: UpdateCommissionStatusDto
    ): Promise<UpdateCommissionResponse> {
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
