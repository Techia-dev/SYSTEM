import type { FastifyReply, FastifyRequest } from "fastify";
import { ApplicationsService } from "./applications.service";
import { ApplicationsRepository } from "./applications.repository";
import type {
    CreateApplicationDto,
    UpdateApplicationStatusDto,
} from "@techia/types";
import { validate } from "../../shared/validation";
import { ListApplicationsQuerySchema, CreateApplicationDtoSchema, UpdateApplicationStatusDtoSchema } from "./applications.schema";
import type { AppError } from "../../shared/error";
import { successResponse, errorResponse } from "../../shared/response";

const service = new ApplicationsService(new ApplicationsRepository());

export class ApplicationsController {
    static async list(
        request: FastifyRequest<{
            Querystring: { page?: string; page_size?: string; status?: string };
        }>,
        reply: FastifyReply
    ) {
        try {
            const query = validate(ListApplicationsQuerySchema, request.query);

            const result = await service.list({
                page: Math.max(1, Number(query?.page) || 1),
                pageSize: Math.min(100, Math.max(1, Number(query?.page_size) || 50)),
                status: query?.status,
            });

            return reply.send(successResponse(result));
        } catch (error) {
            const err = error as AppError;
            return reply.status(err.statusCode ?? 500).send(
                errorResponse(err.message, err.code ?? "UNKNOWN_ERROR")
            );
        }
    }

    static async getById(
        request: FastifyRequest<{ Params: { id: string } }>,
        reply: FastifyReply
    ) {
        try {
            const { id } = request.params;
            const application = await service.getById(id);
            return reply.send(successResponse(application));
        } catch (error) {
            const err = error as AppError;
            return reply.status(err.statusCode ?? 500).send(
                errorResponse(err.message, err.code ?? "UNKNOWN_ERROR")
            );
        }
    }

    static async create(
        request: FastifyRequest<{ Body: CreateApplicationDto }>,
        reply: FastifyReply
    ) {
        try {
            const input = validate(CreateApplicationDtoSchema, request.body);
            const result = await service.create(input);
            return reply.status(201).send(successResponse(result));
        } catch (error) {
            const err = error as AppError;
            return reply.status(err.statusCode ?? 500).send(
                errorResponse(err.message, err.code ?? "UNKNOWN_ERROR")
            );
        }
    }

    static async updateStatus(
        request: FastifyRequest<{
            Params: { id: string };
            Body: UpdateApplicationStatusDto;
        }>,
        reply: FastifyReply
    ) {
        try {
            const { id } = request.params;
            const body = validate(UpdateApplicationStatusDtoSchema, request.body);
            const result = await service.updateStatus(id, body);
            return reply.send(successResponse(result));
        } catch (error) {
            const err = error as AppError;
            return reply.status(err.statusCode ?? 500).send(
                errorResponse(err.message, err.code ?? "UNKNOWN_ERROR")
            );
        }
    }
}
