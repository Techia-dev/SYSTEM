import { FastifyPluginAsync } from "fastify";
import bcrypt from "bcryptjs";

export interface LoginDto {
    email: string;
    password: string;
}

export interface LoginResponse {
    token: string;
    expiresIn: string;
    user: {
        id: string;
        email: string;
        name: string | null;
        role: string;
    };
}

export interface MeResponse {
    user: {
        id: string;
        email: string;
        name: string | null;
        role: string;
    };
}

const authRoutes: FastifyPluginAsync = async (fastify) => {

    // ── POST /auth/login ─────────────────────────────────
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
            config: {
                rateLimit: {
                    max: 5,
                    timeWindow: "1 minute",
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

            const response: LoginResponse = {
                token,
                expiresIn: fastify.authConfig.accessTokenTtl,
                user: {
                    id: user.id,
                    email: user.email,
                    name: user.name,
                    role: user.role,
                },
            };

            return reply.send(response);
        },
    );

    // ── GET /auth/me ────────────────────────────────────
    fastify.get(
        "/me",
        { preHandler: [fastify.requireAuth] },
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

            const response: MeResponse = { user };
            return reply.send(response);
        },
    );

    // ── POST /auth/logout ───────────────────────────────
    fastify.post(
        "/logout",
        { preHandler: [fastify.requireAuth] },
        async (_request, reply) => {
            return reply.send({ message: "Logged out successfully" });
        },
    );
};

export default authRoutes;
