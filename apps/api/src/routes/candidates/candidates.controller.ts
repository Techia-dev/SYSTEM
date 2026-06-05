import { FastifyReply, FastifyRequest } from "fastify";
import { CandidatesService } from "./candidates.service";
import { CandidateLevel } from "@prisma/client";
import { CreateCandidateDto } from "@techia/types";

const service = new CandidatesService();

// helper (safe enum guard)
const isCandidateLevel = (value?: string): value is CandidateLevel => {
    return (
        value === "junior" ||
        value === "mid" ||
        value === "senior" ||
        value === "lead"
    );
};

export class CandidatesController {
    static async list(
        request: FastifyRequest<{
            Querystring: {
                page?: string;
                page_size?: string;
                search?: string;
                level?: string;
            };
        }>,
        reply: FastifyReply
    ) {
        const q = request.query;

        const level = isCandidateLevel(q.level) ? q.level : undefined;

        const result = await service.list({
            page: Math.max(1, Number(q.page) || 1),
            pageSize: Math.min(100, Math.max(1, Number(q.page_size) || 50)),
            search: q.search,
            level,
        });

        return reply.send(result);
    }

    static async create(
        request: FastifyRequest<{ Body: CreateCandidateDto }>,
        reply: FastifyReply
    ) {
        const result = await service.create(request.body);

        return reply.status(201).send(result);
    }
}