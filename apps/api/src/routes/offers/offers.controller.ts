import type { FastifyReply, FastifyRequest } from "fastify";
import { OffersService } from "./offers.service";
import { OffersRepository } from "./offers.repository";
import type {
    CreateOfferDto,
    UpdateOfferDto,
} from "@techia/types";
import { validate } from "../../shared/validation";
import { ListOffersQuerySchema, CreateOfferDtoSchema, UpdateOfferDtoSchema } from "./offers.schema";
import { successResponse } from "../../shared/response";

const service = new OffersService(new OffersRepository());

export class OffersController {
    static async list(
        request: FastifyRequest<{
            Querystring: { page?: string; page_size?: string };
        }>,
        reply: FastifyReply
    ) {
        const query = validate(ListOffersQuerySchema, request.query);
        const queryPage = Math.max(1, Number(query.page) || 1);
        const pageSize = Math.min(
            100,
            Math.max(1, Number(query.page_size) || 50)
        );

        const result = await service.list({ page: queryPage, pageSize });

        return reply.send(successResponse(result));
    }

    static async getById(
        request: FastifyRequest<{ Params: { id: string } }>,
        reply: FastifyReply
    ) {
        const { id } = request.params;
        const offer = await service.getById(id);
        return reply.send(successResponse(offer));
    }

    static async create(
        request: FastifyRequest<{ Body: CreateOfferDto }>,
        reply: FastifyReply
    ) {
        const input = validate(CreateOfferDtoSchema, request.body);
        const result = await service.create(input);

        return reply.status(201).send(successResponse(result));
    }

    static async update(
        request: FastifyRequest<{
            Params: { id: string };
            Body: UpdateOfferDto;
        }>,
        reply: FastifyReply
    ) {
        const { id } = request.params;
        const input = validate(UpdateOfferDtoSchema, request.body);
        const result = await service.update(id, input);
        return reply.send(successResponse(result));
    }

    static async delete(
        request: FastifyRequest<{ Params: { id: string } }>,
        reply: FastifyReply
    ) {
        const { id } = request.params;
        const result = await service.softDelete(id);
        return reply.send(successResponse(result));
    }
}
