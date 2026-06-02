import { FastifyPluginAsync } from "fastify";
import type {
    CreateOfferDto,
    UpdateOfferDto,
    CreateOfferResponse,
} from "@techia/types";

// ============================================================
// Offers Routes
//
// GET    /api/offers      → list all
// GET    /api/offers/:id  → get single
// POST   /api/offers      → create
// PUT    /api/offers/:id  → update
// DELETE /api/offers/:id  → soft delete (isActive = false)
// ============================================================

const offerRoutes: FastifyPluginAsync = async (fastify) => {

    // ── GET /api/offers ──────────────────────────────────────
    fastify.get("/", async (_request, reply) => {
        const offers = await fastify.prisma.offer.findMany({
            orderBy: { createdAt: "desc" },
        });

        return reply.send(offers);
    });

    // ── GET /api/offers/:id ──────────────────────────────────
    fastify.get<{ Params: { id: string } }>(
        "/:id",
        async (request, reply) => {
            const { id } = request.params;

            const offer = await fastify.prisma.offer.findUnique({
                where: { id },
                include: {
                    _count: { select: { applications: true } },
                },
            });

            if (!offer) {
                return reply.status(404).send({
                    success: false,
                    error: "Offer not found",
                });
            }

            return reply.send(offer);
        }
    );

    // ── POST /api/offers ─────────────────────────────────────
    fastify.post<{ Body: CreateOfferDto }>(
        "/",
        {
            schema: {
                body: {
                    type: "object",
                    required: ["title"],
                    properties: {
                        title: { type: "string", minLength: 2 },
                        company: { type: "string" },
                        description: { type: "string" },
                        commission: { type: "number", minimum: 0, default: 0 },
                        commissionDelay: { type: "integer", minimum: 0, default: 0 },
                        isActive: { type: "boolean", default: true },
                    },
                },
            },
        },
        async (request, reply) => {
            const {
                title,
                company,
                description,
                commission = 0,
                commissionDelay = 0,
                isActive = true,
            } = request.body;

            const offer = await fastify.prisma.offer.create({
                data: {
                    title,
                    company: company ?? null,
                    description: description ?? null,
                    commission,
                    commissionDelay,
                    isActive,
                },
            });

            const response: CreateOfferResponse = {
                id: offer.id,
                message: "Offer created",
            };

            return reply.status(201).send(response);
        }
    );

    // ── PUT /api/offers/:id ──────────────────────────────────
    fastify.put<{
        Params: { id: string };
        Body: UpdateOfferDto;
    }>(
        "/:id",
        {
            schema: {
                params: {
                    type: "object",
                    required: ["id"],
                    properties: { id: { type: "string" } },
                },
                body: {
                    type: "object",
                    properties: {
                        title: { type: "string", minLength: 2 },
                        company: { type: "string" },
                        description: { type: "string" },
                        commission: { type: "number", minimum: 0 },
                        commissionDelay: { type: "integer", minimum: 0 },
                        isActive: { type: "boolean" },
                    },
                },
            },
        },
        async (request, reply) => {
            const { id } = request.params;

            const existing = await fastify.prisma.offer.findUnique({
                where: { id },
            });

            if (!existing) {
                return reply.status(404).send({
                    success: false,
                    error: "Offer not found",
                });
            }

            const data = Object.fromEntries(
                Object.entries(request.body).filter(([, v]) => v !== undefined)
            );

            const offer = await fastify.prisma.offer.update({
                where: { id },
                data,
            });

            return reply.send(offer);
        }
    );

    // ── DELETE /api/offers/:id ───────────────────────────────
    // Soft delete — isActive = false
    fastify.delete<{ Params: { id: string } }>(
        "/:id",
        async (request, reply) => {
            const { id } = request.params;

            await fastify.prisma.offer.update({
                where: { id },
                data: { isActive: false },
            });

            return reply.send({ message: "Offer deactivated" });
        }
    );
};

export default offerRoutes;