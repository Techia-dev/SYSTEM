import "dotenv/config";
import { startServer } from "./app/server";

process.on("unhandledRejection", (reason) => {
    console.error("UNHANDLED REJECTION:", reason);
});

process.on("uncaughtException", (error) => {
    console.error("UNCAUGHT EXCEPTION:", error);
    process.exit(1);
});

console.log("Starting server...");

startServer().catch((err: unknown) => {
    console.error("Failed to start server:", err);
    process.exit(1);
});