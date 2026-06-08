import { FastifyPluginAsync } from "fastify";
import { CommissionsController } from "./commissions.controller";
import type { UpdateCommissionStatusDto } from "@techia/types";

const commissionRoutes: FastifyPluginAsync = async (fastify) => {
    fastify.addHook("onRequest", fastify.requirePermission("commissions:read"));

    fastify.get<{
        Querystring: { page?: string; page_size?: string; status?: string };
    }>("/", CommissionsController.list);

    fastify.get<{ Params: { id: string } }>(
        "/:id",
        CommissionsController.getById
    );

    fastify.patch<{
        Params: { id: string };
        Body: UpdateCommissionStatusDto;
    }>(
        "/:id/status",
        { preHandler: [fastify.requirePermission("commissions:write")] },
        CommissionsController.updateStatus
    );
};

export default commissionRoutes;
