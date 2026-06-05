import { FastifyReply, FastifyRequest } from "fastify";
import type {
    CreateCandidateDto,
    ListCandidatesQueryDto,
    ListCandidatesResponse,
} from "@techia/types";

import { CandidatesService } from "./candidates.service";
import { CandidatesRepository } from "./candidates.repository";
import { validate } from "../../shared/validation";
import { ListCandidatesQuerySchema, CreateCandidateDtoSchema } from "./candidates.schema";
import type { AppError } from "../../shared/error";
import { successResponse, errorResponse } from "../../shared/response";

const service = new CandidatesService(new CandidatesRepository());

export class CandidatesController {
    static async list(
        request: FastifyRequest<{ Querystring: ListCandidatesQueryDto }>,
        reply: FastifyReply
    ) {
        try {
            const query = validate(ListCandidatesQuerySchema, request.query);

            const result: ListCandidatesResponse = await service.list({
                page: Math.max(1, Number(query?.page ?? 1)),
                pageSize: Math.min(100, Number(query?.page_size ?? 50)),
                search: query?.search,
                level: query?.level,
            });

            return reply.send(successResponse(result));
        } catch (error) {
            const err = error as AppError;
            return reply
                .status(err.statusCode ?? 500)
                .send(errorResponse(err.message, err.code ?? "UNKNOWN_ERROR"));
        }
    }

    static async create(
        request: FastifyRequest<{ Body: CreateCandidateDto }>,
        reply: FastifyReply
    ) {
        try {
            const input = validate(CreateCandidateDtoSchema, request.body);
            const result = await service.create(input);
            return reply.status(201).send(successResponse(result));
        } catch (error) {
            const err = error as AppError;
            return reply
                .status(err.statusCode ?? 500)
                .send(errorResponse(err.message, err.code ?? "UNKNOWN_ERROR"));
        }
    }
}