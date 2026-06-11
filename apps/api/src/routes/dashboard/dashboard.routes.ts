import { FastifyPluginAsync } from "fastify";
import { DashboardController } from "./dashboard.controller";

const dashboardRoutes: FastifyPluginAsync = async (fastify) => {
    fastify.get("/stats", {
        preHandler: [fastify.requireAuth, fastify.requirePermission("dashboard:read")],
    }, DashboardController.stats);

    fastify.get("/analytics", {
        preHandler: [fastify.requireAuth, fastify.requirePermission("dashboard:read")],
    }, DashboardController.analytics);
};

export default dashboardRoutes;
