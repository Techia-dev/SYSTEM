import { FastifyPluginAsync } from "fastify";
import { ApplicationsController } from "./applications.controller";
import type {
    CreateApplicationDto,
    UpdateApplicationStatusDto,
} from "@techia/types";

const applicationRoutes: FastifyPluginAsync = async (fastify) => {
    fastify.addHook("onRequest", fastify.requirePermission("applications:read"));

    fastify.get<{
        Querystring: { page?: string; page_size?: string; status?: string };
    }>("/", ApplicationsController.list);

    fastify.get<{ Params: { id: string } }>(
        "/:id",
        ApplicationsController.getById
    );

    fastify.post<{ Body: CreateApplicationDto }>(
        "/",
        { preHandler: [fastify.requirePermission("applications:write")] },
        ApplicationsController.create
    );

    fastify.put<{
        Params: { id: string };
        Body: UpdateApplicationStatusDto;
    }>(
        "/:id/status",
        { preHandler: [fastify.requirePermission("applications:status")] },
        ApplicationsController.updateStatus
    );
};

export default applicationRoutes;
