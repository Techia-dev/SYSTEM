import { FastifyPluginAsync } from "fastify";
import { CandidatesController } from "./candidates.controller";
import type {
    CreateCandidateDto,
    ListCandidatesQueryDto
} from "@techia/types";

const routes: FastifyPluginAsync = async (fastify) => {
    fastify.addHook("onRequest", fastify.requirePermission("candidates:read"));

    fastify.get<{
        Querystring: ListCandidatesQueryDto;
    }>("/", CandidatesController.list);

    fastify.post<{
        Body: CreateCandidateDto;
    }>(
        "/",
        { preHandler: [fastify.requirePermission("candidates:write")] },
        CandidatesController.create
    );
};

export default routes;