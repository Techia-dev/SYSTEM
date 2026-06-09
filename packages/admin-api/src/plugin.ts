import fp from "fastify-plugin";
import { FastifyInstance, FastifyRequest, FastifyReply } from "fastify";
import type { PrismaClient } from "@prisma/client";
import "@fastify/jwt";

export type Permission =
    | "*"
    | "candidates:read"
    | "candidates:write"
    | "offers:read"
    | "offers:write"
    | "applications:read"
    | "applications:write"
    | "applications:status"
    | "commissions:read"
    | "commissions:write";

type AuthGuard = (request: FastifyRequest, reply: FastifyReply) => Promise<void>;

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
        authConfig: {
            accessTokenTtl: string;
        };
        authenticate: AuthGuard;
        requireAuth: AuthGuard;
        requireRole: (...roles: string[]) => AuthGuard;
        requirePermission: (permission: Permission) => AuthGuard;
        prisma: PrismaClient;
    }

    interface FastifyRequest {
        userId: string;
        userRole: string;
    }
}

export interface AuthPluginOptions {
    secret: string;
    accessTokenTtl?: string;
}

const permissionsByRole: Record<string, readonly Permission[]> = {
    admin: ["*"],
    user: [
        "candidates:read",
        "candidates:write",
        "offers:read",
        "applications:read",
        "applications:write",
        "commissions:read",
    ],
};

function roleHasPermission(role: string, permission: Permission) {
    const permissions = permissionsByRole[role] ?? [];
    return permissions.includes("*") || permissions.includes(permission);
}

async function authPlugin(
    fastify: FastifyInstance,
    opts: AuthPluginOptions,
) {
    const accessTokenTtl = opts.accessTokenTtl ?? "15m";

    await fastify.register(import("@fastify/jwt"), {
        secret: opts.secret,
        sign: {
            expiresIn: accessTokenTtl,
        },
    });

    fastify.decorate("authConfig", { accessTokenTtl });

    fastify.decorate(
        "authenticate",
        async function (request: FastifyRequest, reply: FastifyReply) {
            try {
                await request.jwtVerify();

                const user = await fastify.prisma.user.findUnique({
                    where: { id: request.user.id },
                    select: { id: true, role: true, isActive: true },
                });

                if (!user || !user.isActive) {
                    reply.status(401).send({
                        success: false,
                        error: "Unauthorized - user is inactive or no longer exists",
                    });
                    return;
                }

                request.userId = user.id;
                request.userRole = user.role ?? "user";
            } catch {
                reply.status(401).send({
                    success: false,
                    error: "Unauthorized - invalid or expired token",
                });
                return;
            }
        },
    );

    fastify.decorate("requireAuth", fastify.authenticate);

    fastify.decorate(
        "requireRole",
        (...roles: string[]) =>
            async function (request: FastifyRequest, reply: FastifyReply) {
                if (!request.userId) {
                    await fastify.authenticate(request, reply);
                    if (reply.sent) return;
                }

                if (!roles.includes(request.userRole)) {
                    reply.status(403).send({
                        success: false,
                        error: "Forbidden - insufficient role",
                    });
                    return;
                }
            },
    );

    fastify.decorate(
        "requirePermission",
        (permission: Permission) =>
            async function (request: FastifyRequest, reply: FastifyReply) {
                if (!request.userId) {
                    await fastify.authenticate(request, reply);
                    if (reply.sent) return;
                }

                if (!roleHasPermission(request.userRole, permission)) {
                    reply.status(403).send({
                        success: false,
                        error: "Forbidden - insufficient permission",
                    });
                    return;
                }
            },
    );

    fastify.decorateRequest("userId", "");
    fastify.decorateRequest("userRole", "");
}

export default fp(authPlugin, {
    name: "techia-auth",
    dependencies: [],
});
