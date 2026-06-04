import { FastifyPluginAsync } from "fastify";
import bcrypt from "bcryptjs";
import type { LoginDto } from "@techia/types";

const authRoutes: FastifyPluginAsync = async (fastify) => {

    // ── POST /api/auth/login ───────────────────────────────
    fastify.post<{ Body: LoginDto }>(
        "/login",
        {
            schema: {
                body: {
                    type: "object",
                    required: ["email", "password"],
                    properties: {
                        email: { type: "string", format: "email" },
                        password: { type: "string", minLength: 1 },
                    },
                },
            },
        },
        async (request, reply) => {
            const { email, password } = request.body;

            const user = await fastify.prisma.user.findUnique({
                where: { email },
            });

            if (!user || !user.isActive) {
                return reply.status(401).send({
                    success: false,
                    error: "Invalid email or password",
                });
            }

            const valid = await bcrypt.compare(password, user.password);
            if (!valid) {
                return reply.status(401).send({
                    success: false,
                    error: "Invalid email or password",
                });
            }

            const token = await reply.jwtSign({
                id: user.id,
                email: user.email,
                role: user.role,
            });

            return reply.send({
                token,
                user: {
                    id: user.id,
                    email: user.email,
                    name: user.name,
                    role: user.role,
                },
            });
        }
    );

    // ── GET /api/auth/me ──────────────────────────────────
    fastify.get(
        "/me",
        { preHandler: [fastify.authenticate] },
        async (request, reply) => {
            const user = await fastify.prisma.user.findUnique({
                where: { id: request.userId },
                select: { id: true, email: true, name: true, role: true },
            });

            if (!user) {
                return reply.status(404).send({
                    success: false,
                    error: "User not found",
                });
            }

            return reply.send({ user });
        }
    );

    // ── POST /api/auth/logout ─────────────────────────────
    fastify.post(
        "/logout",
        { preHandler: [fastify.authenticate] },
        async (_request, reply) => {
            // JWT is stateless — client should discard the token
            return reply.send({ message: "Logged out successfully" });
        }
    );
};

export default authRoutes;
