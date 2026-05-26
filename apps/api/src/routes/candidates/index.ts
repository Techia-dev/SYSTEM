import { FastifyPluginAsync } from "fastify";
import { CandidateLevel } from "@prisma/client";

// ============================================================
// Candidates Routes
// محوّلة من: server/controllers/candidateController.js
//
// GET  /api/candidates       → getCandidates
// POST /api/candidates       → createCandidate
// ============================================================

const candidateRoutes: FastifyPluginAsync = async (fastify) => {

    // ── GET /api/candidates ────────────────────────────────────
    // كان: db.collection("candidates").get()
    fastify.get("/", async (request, reply) => {
        const candidates = await fastify.prisma.candidate.findMany({
            orderBy: { createdAt: "desc" },
        });

        return reply.send(candidates);
    });

    // ── POST /api/candidates ───────────────────────────────────
    // كان: db.collection("candidates").add({ name, phone, level })
    fastify.post<{
        Body: {
            name: string;
            phone: string;
            email?: string;
            level?: CandidateLevel;
        };
    }>(
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

            return reply.status(201).send({
                id: candidate.id,
                message: "Candidate created",
            });
        }
    );
};

export default candidateRoutes;