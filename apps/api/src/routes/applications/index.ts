import { FastifyPluginAsync } from "fastify";
import type {
    CreateApplicationDto,
    UpdateApplicationStatusDto,
    CreateApplicationResponse,
    UpdateStatusResponse,
} from "@techia/types";

// ============================================================
// Applications Routes
//
// GET  /api/applications              → list all
// GET  /api/applications/:id          → get single
// POST /api/applications              → create
// PUT  /api/applications/:id/status   → update status + auto commission
// ============================================================

const applicationRoutes: FastifyPluginAsync = async (fastify) => {
    fastify.addHook("onRequest", fastify.authenticate);

    // ── GET /api/applications ────────────────────────────────
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

        const [applications, total] = await Promise.all([
            fastify.prisma.application.findMany({
                where,
                orderBy: { createdAt: "desc" },
                skip,
                take: pageSize,
                include: {
                    candidate: {
                        select: { id: true, name: true, phone: true, level: true },
                    },
                    offer: {
                        select: { id: true, title: true, company: true, commission: true },
                    },
                },
            }),
            fastify.prisma.application.count({ where }),
        ]);

        return reply.send({
            data: applications,
            total,
            page: queryPage,
            page_size: pageSize,
            total_pages: Math.ceil(total / pageSize),
        });
    });

    // ── GET /api/applications/:id ────────────────────────────
    fastify.get<{ Params: { id: string } }>(
        "/:id",
        async (request, reply) => {
            const { id } = request.params;

            const application = await fastify.prisma.application.findUnique({
                where: { id },
                include: {
                    candidate: true,
                    offer: true,
                    commission: true,
                },
            });

            if (!application) {
                return reply.status(404).send({
                    success: false,
                    error: "Application not found",
                });
            }

            return reply.send(application);
        }
    );

    // ── POST /api/applications ───────────────────────────────
    fastify.post<{ Body: CreateApplicationDto }>(
        "/",
        {
            schema: {
                body: {
                    type: "object",
                    required: ["candidateId", "offerId"],
                    properties: {
                        candidateId: { type: "string" },
                        offerId: { type: "string" },
                        source: { type: "string" },
                        assignedTo: { type: "string" },
                    },
                },
            },
        },
        async (request, reply) => {
            const { candidateId, offerId, source, assignedTo } = request.body;

            const [candidate, offer] = await Promise.all([
                fastify.prisma.candidate.findUnique({ where: { id: candidateId } }),
                fastify.prisma.offer.findUnique({ where: { id: offerId } }),
            ]);

            if (!candidate || !offer) {
                return reply.status(400).send({
                    success: false,
                    error: !candidate ? "Candidate not found" : "Offer not found",
                });
            }

            const application = await fastify.prisma.application.create({
                data: {
                    candidateId,
                    offerId,
                    source: source ?? null,
                    assignedTo: assignedTo ?? null,
                    status: "applied",
                },
            });

            const response: CreateApplicationResponse = {
                id: application.id,
                message: "Application created successfully",
            };

            return reply.status(201).send(response);
        }
    );

    // ── PUT /api/applications/:id/status ─────────────────────
    // عند accepted → ينشئ commission تلقائياً عبر transaction
    const validTransitions: Record<string, string[]> = {
        applied: ["interview", "rejected"],
        interview: ["accepted", "rejected"],
        accepted: [],
        rejected: [],
    };

    fastify.put<{
        Params: { id: string };
        Body: UpdateApplicationStatusDto;
    }>(
        "/:id/status",
        {
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
                            enum: ["applied", "interview", "accepted", "rejected"],
                        },
                    },
                },
            },
        },
        async (request, reply) => {
            const { id } = request.params;
            const { status } = request.body;

            const application = await fastify.prisma.application.findUnique({
                where: { id },
                include: { offer: true },
            });

            if (!application) {
                return reply.status(404).send({
                    success: false,
                    error: "Application not found",
                });
            }

            const allowed = validTransitions[application.status];
            if (!allowed.includes(status)) {
                return reply.status(400).send({
                    success: false,
                    error: `Cannot transition from "${application.status}" to "${status}"`,
                });
            }

            if (status === "accepted") {
                const existingCommission = await fastify.prisma.commission.findUnique({
                    where: { applicationId: id },
                });

                if (!existingCommission) {
                    const dueDate = new Date();
                    dueDate.setDate(dueDate.getDate() + application.offer.commissionDelay);

                    await fastify.prisma.$transaction([
                        fastify.prisma.application.update({
                            where: { id },
                            data: { status },
                        }),
                        fastify.prisma.commission.create({
                            data: {
                                applicationId: id,
                                offerId: application.offer.id,
                                candidateId: application.candidateId,
                                amount: application.offer.commission,
                                status: "pending",
                                earnedAt: new Date(),
                                dueDate,
                            },
                        }),
                    ]);

                    const response: UpdateStatusResponse = {
                        success: true,
                        message: "Status updated to accepted and commission generated",
                    };

                    return reply.send(response);
                }
            }

            await fastify.prisma.application.update({
                where: { id },
                data: { status },
            });

            const response: UpdateStatusResponse = {
                success: true,
                message: `Status updated to ${status}`,
            };

            return reply.send(response);
        }
    );
};

export default applicationRoutes;