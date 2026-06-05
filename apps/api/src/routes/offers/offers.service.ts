import { OffersRepository } from "./offers.repository";
import type {
    CreateOfferDto,
    UpdateOfferDto,
    PaginatedResponse,
} from "@techia/types";

export class OffersService {
    constructor(private readonly repository: OffersRepository) {}

    async list(params: { page: number; pageSize: number }): Promise<PaginatedResponse<unknown>> {
        const skip = (params.page - 1) * params.pageSize;

        const [offers, total] = await Promise.all([
            this.repository.findMany({
                skip,
                take: params.pageSize,
                orderBy: { createdAt: "desc" },
            }),
            this.repository.count(),
        ]);

        return {
            data: offers,
            total,
            page: params.page,
            page_size: params.pageSize,
            total_pages: Math.ceil(total / params.pageSize),
        };
    }

    async getById(id: string) {
        const offer = await this.repository.findUnique(id, {
            _count: { select: { applications: true } },
        });

        return offer;
    }

    async create(input: CreateOfferDto) {
        const offer = await this.repository.create({
            title: input.title,
            company: input.company ?? null,
            description: input.description ?? null,
            commission: input.commission ?? 0,
            commissionDelay: input.commissionDelay ?? 0,
            isActive: input.isActive ?? true,
        });

        return {
            id: offer.id,
            message: "Offer created",
        };
    }

    async update(id: string, input: UpdateOfferDto) {
        const existing = await this.repository.findUnique(id);

        if (!existing) {
            throw Object.assign(new Error("Offer not found"), {
                statusCode: 404,
            });
        }

        const data: Record<string, unknown> = {};
        if (input.title !== undefined) data.title = input.title;
        if (input.company !== undefined) data.company = input.company;
        if (input.description !== undefined) data.description = input.description;
        if (input.commission !== undefined) data.commission = input.commission;
        if (input.commissionDelay !== undefined) data.commissionDelay = input.commissionDelay;
        if (input.isActive !== undefined) data.isActive = input.isActive;

        const offer = await this.repository.update(id, data);

        return offer;
    }

    async softDelete(id: string) {
        const existing = await this.repository.findUnique(id);

        if (!existing) {
            throw Object.assign(new Error("Offer not found"), {
                statusCode: 404,
            });
        }

        await this.repository.update(id, { isActive: false });

        return { message: "Offer deactivated" };
    }
}
