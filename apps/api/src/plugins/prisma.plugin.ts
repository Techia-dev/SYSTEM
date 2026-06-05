import fp from "fastify-plugin";
import { FastifyInstance } from "fastify";
import { prisma } from "@techia/db";

async function prismaPlugin(fastify: FastifyInstance) {
    await fastify.decorate("prisma", prisma);

    fastify.addHook("onClose", async () => {
        await prisma.$disconnect();
    });
}

export default fp(prismaPlugin, {
    name: "techia-prisma",
});
