import fp from "fastify-plugin";
import { FastifyInstance } from "fastify";
import { config } from "../config";

async function corsPlugin(fastify: FastifyInstance) {
    fastify.addHook("onRequest", async (request, reply) => {
        const requestOrigin = request.headers.origin;

        if (
            requestOrigin &&
            (config.corsOrigins.includes("*") || config.corsOrigins.includes(requestOrigin))
        ) {
            reply.header("Access-Control-Allow-Origin", requestOrigin);
            reply.header("Vary", "Origin");
        }

        reply.header(
            "Access-Control-Allow-Methods",
            "GET,POST,PUT,PATCH,DELETE,OPTIONS",
        );
        reply.header(
            "Access-Control-Allow-Headers",
            "Content-Type,Authorization",
        );
        reply.header("Access-Control-Allow-Credentials", "true");

        if (request.method === "OPTIONS") {
            return reply.status(204).send();
        }
    });
}

export default fp(corsPlugin);
