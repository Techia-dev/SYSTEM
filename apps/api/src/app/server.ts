import { buildApp } from "./buildApp";

export const startServer = async () => {
    const app = buildApp();

    await app.listen({
        port: Number(process.env.PORT ?? 3000),
        host: "0.0.0.0",
    });

    const shutdown = async (signal: string) => {
        app.log.info(`Received ${signal}, shutting down...`);
        await app.close();
        process.exit(0);
    };

    process.on("SIGINT", () => shutdown("SIGINT"));
    process.on("SIGTERM", () => shutdown("SIGTERM"));
};