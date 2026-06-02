import fp from "fastify-plugin";
import { FastifyInstance } from "fastify";
import { prisma } from "@techia/db";

declare module "fastify" {
    interface FastifyInstance {
        prisma: typeof prisma;
    }
}

async function databasePlugin(fastify: FastifyInstance) {
    await prisma.$connect();

    fastify.decorate("prisma", prisma);

    fastify.addHook("onClose", async (instance) => {
        await instance.prisma.$disconnect();
    });

    fastify.log.info("✅ Database connected");
}

export default fp(databasePlugin);