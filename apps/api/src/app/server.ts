import { buildApp } from "./buildApp";
import { config } from "../config";

export const startServer = async () => {
    const app = buildApp();

    await app.listen({
        port: config.port,
        host: config.host,
    });

    const shutdown = async (signal: string) => {
        app.log.info(`Received ${signal}, shutting down...`);
        await app.close();
        process.exit(0);
    };

    process.on("SIGINT", () => shutdown("SIGINT"));
    process.on("SIGTERM", () => shutdown("SIGTERM"));
};
