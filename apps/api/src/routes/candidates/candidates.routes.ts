import { FastifyPluginAsync } from "fastify";
import { CandidatesController } from "./candidates.controller";

const routes: FastifyPluginAsync = async (fastify) => {
    fastify.get("/", CandidatesController.list);

    fastify.post("/", CandidatesController.create);
};

export default routes;