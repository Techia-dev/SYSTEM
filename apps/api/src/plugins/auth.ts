import fp from "fastify-plugin";
import { FastifyInstance, FastifyRequest, FastifyReply } from "fastify";
import "@fastify/jwt";

declare module "@fastify/jwt" {
    interface FastifyJWT {
        user: {
            id: string;
            email: string;
            role: string;
        };
    }
}

declare module "fastify" {
    interface FastifyInstance {
        authenticate: (request: FastifyRequest, reply: FastifyReply) => Promise<void>;
    }

    interface FastifyRequest {
        userId: string;
        userRole: string;
    }
}

async function authPlugin(fastify: FastifyInstance) {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
        throw new Error(
            "\n❌ Missing required environment variable: JWT_SECRET\n" +
            "   Add JWT_SECRET to apps/api/.env (e.g., JWT_SECRET=your-secret-key)\n"
        );
    }

    await fastify.register(import("@fastify/jwt"), { secret });

    fastify.decorate(
        "authenticate",
        async function (request: FastifyRequest, reply: FastifyReply) {
            try {
                await request.jwtVerify();
                request.userId = request.user.id;
                request.userRole = request.user.role ?? "user";
            } catch {
                return reply.status(401).send({
                    success: false,
                    error: "Unauthorized - invalid or expired token",
                });
            }
        }
    );

    fastify.decorateRequest("userId", "");
    fastify.decorateRequest("userRole", "");
}

export default fp(authPlugin);
