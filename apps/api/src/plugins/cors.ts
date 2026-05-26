import { FastifyInstance } from "fastify";

// ============================================================
// CORS Plugin
// مكتوب يدوياً بدون @fastify/cors
// نفس إعدادات الـ Express القديم: app.use(cors())
// ============================================================

export default async function corsPlugin(fastify: FastifyInstance) {
    const origin = process.env.CORS_ORIGIN || "*";

    fastify.addHook("onRequest", async (request, reply) => {
        reply.header("Access-Control-Allow-Origin", origin);
        reply.header("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,PATCH,OPTIONS");
        reply.header("Access-Control-Allow-Headers", "Content-Type,Authorization");

        // Preflight
        if (request.method === "OPTIONS") {
            reply.status(204).send();
        }
    });
}