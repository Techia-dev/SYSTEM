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

    // ── GET /api/applications ────────────────────────────────
    fastify.get("/", async (_request, reply) => {
        const applications = await fastify.prisma.application.findMany({
            orderBy: { createdAt: "desc" },
            include: {
                candidate: {
                    select: { id: true, name: true, phone: true, level: true },
                },
                offer: {
                    select: { id: true, title: true, company: true, commission: true },
                },
            },
        });

        return reply.send(applications);
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

            if (status === "accepted") {
                const { offer } = application;

                const existingCommission = await fastify.prisma.commission.findUnique({
                    where: { applicationId: id },
                });

                if (!existingCommission) {
                    const dueDate = new Date();
                    dueDate.setDate(dueDate.getDate() + offer.commissionDelay);

                    await fastify.prisma.$transaction([
                        fastify.prisma.application.update({
                            where: { id },
                            data: { status },
                        }),
                        fastify.prisma.commission.create({
                            data: {
                                applicationId: id,
                                offerId: offer.id,
                                candidateId: application.candidateId,
                                amount: offer.commission,
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