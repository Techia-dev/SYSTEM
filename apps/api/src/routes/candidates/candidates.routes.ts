import { FastifyPluginAsync } from "fastify";
import { CandidatesController } from "./candidates.controller";
import type {
    CreateCandidateDto,
    ListCandidatesQueryDto
} from "@techia/types";

const routes: FastifyPluginAsync = async (fastify) => {

    fastify.get<{
        Querystring: ListCandidatesQueryDto;
    }>("/", CandidatesController.list);

    fastify.post<{
        Body: CreateCandidateDto;
    }>("/", CandidatesController.create);
};

export default routes;