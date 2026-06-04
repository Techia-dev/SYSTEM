import { FastifyPluginAsync } from "fastify";
import type {
    UpdateCommissionStatusDto,
    UpdateCommissionResponse,
} from "@techia/types";

const commissionRoutes: FastifyPluginAsync = async (fastify) => {
    fastify.addHook("onRequest", fastify.requirePermission("commissions:read"));

    // ── GET /api/commissions ─────────────────────────────────
    fastify.get<{
        Querystring: { page?: string; page_size?: string; status?: string };
    }>("/", async (request, reply) => {
        const queryPage = Math.max(1, Number(request.query.page) || 1);
        const pageSize = Math.min(100, Math.max(1, Number(request.query.page_size) || 50));
        const skip = (queryPage - 1) * pageSize;

        const where: Record<string, unknown> = {};
        if (request.query.status) {
            where.status = request.query.status;
        }

        const [commissions, total] = await Promise.all([
            fastify.prisma.commission.findMany({
                where,
                orderBy: { createdAt: "desc" },
                skip,
                take: pageSize,
                include: {
                    candidate: {
                        select: { id: true, name: true, phone: true },
                    },
                    offer: {
                        select: { id: true, title: true, company: true },
                    },
                },
            }),
            fastify.prisma.commission.count({ where }),
        ]);

        return reply.send({
            data: commissions,
            total,
            page: queryPage,
            page_size: pageSize,
            total_pages: Math.ceil(total / pageSize),
        });
    });

    // ── GET /api/commissions/:id ─────────────────────────────
    fastify.get<{ Params: { id: string } }>(
        "/:id",
        async (request, reply) => {
            const { id } = request.params;

            const commission = await fastify.prisma.commission.findUnique({
                where: { id },
                include: {
                    candidate: true,
                    offer: true,
                    application: {
                        select: { id: true, status: true, source: true },
                    },
                },
            });

            if (!commission) {
                return reply.status(404).send({
                    success: false,
                    error: "Commission not found",
                });
            }

            return reply.send(commission);
        }
    );

    // ── PATCH /api/commissions/:id/status ────────────────────
    fastify.patch<{
        Params: { id: string };
        Body: UpdateCommissionStatusDto;
    }>(
        "/:id/status",
        {
            preHandler: [fastify.requirePermission("commissions:write")],
            schema: {
                params: {
                    type: "object",
                    required: ["id"],
                    properties: { id: { type: "string" } },
                },
                body: {
                    type: "object",
                    required: ["status"],
                    properties: {
                        status: {
                            type: "string",
                            enum: ["pending", "paid"],
                        },
                    },
                },
            },
        },
        async (request, reply) => {
            const { id } = request.params;
            const { status } = request.body;

            const commission = await fastify.prisma.commission.update({
                where: { id },
                data: { status },
            });

            const response: UpdateCommissionResponse = {
                id: commission.id,
                status: commission.status,
                message: `Commission marked as ${status}`,
            };

            return reply.send(response);
        }
    );
};

export default commissionRoutes;
