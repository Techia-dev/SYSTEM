import type { FastifyReply, FastifyRequest } from "fastify";
import { CommissionsService } from "./commissions.service";
import { CommissionsRepository } from "./commissions.repository";
import type { UpdateCommissionStatusDto } from "@techia/types";
import type { AppError } from "../../shared/error";
import { validate } from "../../shared/validation";
import { ListCommissionsQuerySchema, UpdateCommissionStatusDtoSchema } from "./commissions.schema";
import { successResponse, errorResponse } from "../../shared/response";

const service = new CommissionsService(new CommissionsRepository());

export class CommissionsController {
    static async list(
        request: FastifyRequest<{
            Querystring: { page?: string; page_size?: string; status?: string };
        }>,
        reply: FastifyReply
    ) {
        try {
            const query = validate(ListCommissionsQuerySchema, request.query);
            const queryPage = Math.max(1, Number(query.page) || 1);
            const pageSize = Math.min(
                100,
                Math.max(1, Number(query.page_size) || 50)
            );

            const result = await service.list({
                page: queryPage,
                pageSize,
                status: query.status,
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
            const commission = await service.getById(id);

            if (!commission) {
                return reply.status(404).send(
                    errorResponse("Commission not found", "NOT_FOUND")
                );
            }

            return reply.send(successResponse(commission));
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
            Body: UpdateCommissionStatusDto;
        }>,
        reply: FastifyReply
    ) {
        try {
            const { id } = request.params;
            const input = validate(UpdateCommissionStatusDtoSchema, request.body);
            const result = await service.updateStatus(id, input);

            return reply.send(successResponse(result));
        } catch (error) {
            const err = error as AppError;
            return reply.status(err.statusCode ?? 500).send(
                errorResponse(err.message, err.code ?? "UNKNOWN_ERROR")
            );
        }
    }
}
