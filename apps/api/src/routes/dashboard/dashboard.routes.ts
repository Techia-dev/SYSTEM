import { FastifyPluginAsync } from "fastify";
import { DashboardController } from "./dashboard.controller";

const dashboardRoutes: FastifyPluginAsync = async (fastify) => {
    fastify.get("/stats", DashboardController.stats);
    fastify.get("/analytics", DashboardController.analytics);
};

export default dashboardRoutes;
