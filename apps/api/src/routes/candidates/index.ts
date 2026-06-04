// apps/api/src/routes/candidates/index.ts
import { FastifyPluginAsync } from "fastify";
import type {
    CreateCandidateDto,
    CreateCandidateResponse,
} from "@techia/types";

const candidateRoutes: FastifyPluginAsync = async (fastify) => {
    fastify.addHook("onRequest", fastify.authenticate);

    // ── GET /api/candidates ──────────────────────────────────
    fastify.get<{
        Querystring: { page?: string; page_size?: string; search?: string; level?: string };
    }>("/", async (request, reply) => {
        const queryPage = Math.max(1, Number(request.query.page) || 1);
        const pageSize = Math.min(100, Math.max(1, Number(request.query.page_size) || 50));
        const skip = (queryPage - 1) * pageSize;

        const where: Record<string, unknown> = {};
        if (request.query.search) {
            where.OR = [
                { name: { contains: request.query.search, mode: "insensitive" } },
                { email: { contains: request.query.search, mode: "insensitive" } },
                { phone: { contains: request.query.search } },
            ];
        }
        if (request.query.level) {
            where.level = request.query.level;
        }

        const [candidates, total] = await Promise.all([
            fastify.prisma.candidate.findMany({
                where,
                orderBy: { createdAt: "desc" },
                skip,
                take: pageSize,
            }),
            fastify.prisma.candidate.count({ where }),
        ]);

        return reply.send({
            data: candidates,
            total,
            page: queryPage,
            page_size: pageSize,
            total_pages: Math.ceil(total / pageSize),
        });
    });

    // ── POST /api/candidates ─────────────────────────────────
    fastify.post<{ Body: CreateCandidateDto }>(
        "/",
        {
            schema: {
                body: {
                    type: "object",
                    required: ["name", "phone"],
                    properties: {
                        name: { type: "string", minLength: 1 },
                        phone: { type: "string", minLength: 1 },
                        email: { type: "string", format: "email" },
                        level: {
                            type: "string",
                            enum: ["junior", "mid", "senior", "lead"],
                        },
                    },
                },
            },
        },
        async (request, reply) => {
            const { name, phone, email, level } = request.body;

            const candidate = await fastify.prisma.candidate.create({
                data: {
                    name,
                    phone,
                    email: email ?? null,
                    level: level ?? "junior",
                },
            });

            const response: CreateCandidateResponse = {
                id: candidate.id,
                message: "Candidate created",
            };

            return reply.status(201).send(response);
        }
    );
};

export default candidateRoutes;