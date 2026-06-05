import { FastifyPluginAsync } from "fastify";
import { OffersController } from "./offers.controller";
import type { CreateOfferDto, UpdateOfferDto } from "@techia/types";

const offerRoutes: FastifyPluginAsync = async (fastify) => {
    fastify.addHook("onRequest", fastify.requirePermission("offers:read"));

    fastify.get<{
        Querystring: { page?: string; page_size?: string };
    }>("/", OffersController.list);

    fastify.get<{ Params: { id: string } }>(
        "/:id",
        OffersController.getById
    );

    fastify.post<{ Body: CreateOfferDto }>(
        "/",
        { preHandler: [fastify.requirePermission("offers:write")] },
        OffersController.create
    );

    fastify.put<{
        Params: { id: string };
        Body: UpdateOfferDto;
    }>(
        "/:id",
        { preHandler: [fastify.requirePermission("offers:write")] },
        OffersController.update
    );

    fastify.delete<{ Params: { id: string } }>(
        "/:id",
        { preHandler: [fastify.requirePermission("offers:write")] },
        OffersController.delete
    );
};

export default offerRoutes;
