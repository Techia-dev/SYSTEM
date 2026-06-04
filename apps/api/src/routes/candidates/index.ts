import { FastifyPluginAsync } from "fastify";
import { CandidatesService } from "../../services/candidates.service";
import { CandidateLevel } from "@prisma/client";

const candidateRoutes: FastifyPluginAsync = async (fastify) => {
    const service = new CandidatesService(fastify.prisma);

    fastify.addHook(
        "onRequest",
        fastify.requirePermission("candidates:read")
    );

    fastify.get("/", async (request, reply) => {
        const query = request.query as {
            page?: string;
            page_size?: string;
            search?: string;
            level?: CandidateLevel;
        };

        const page = Math.max(1, Number(query.page) || 1);
        const pageSize = Math.min(
            100,
            Math.max(1, Number(query.page_size) || 50)
        );

        const result = await service.list({
            page,
            pageSize,
            search: query.search,
            level: query.level,
        });

        return reply.send(result);
    });

    fastify.post(
        "/",
        {
            preHandler: [
                fastify.requirePermission("candidates:write"),
            ],
        },
        async (request, reply) => {
            const body = request.body as {
                name: string;
                phone: string;
                email?: string;
                level?: CandidateLevel;
            };

            const result = await service.create(body);

            return reply.status(201).send(result);
        }
    );
};

export default candidateRoutes;