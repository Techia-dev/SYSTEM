import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as {
    prisma?: PrismaClient;
};

function createPrismaClient() {
    return new PrismaClient({
        log:
            process.env.PRISMA_LOG_QUERIES === "true"
                ? ["query", "warn", "error"]
                : ["warn", "error"],
    });
}

export const prisma =
    globalForPrisma.prisma ?? createPrismaClient();

if (process.env.NODE_ENV !== "production") {
    globalForPrisma.prisma = prisma;
}

process.on("SIGINT", async () => {
    await prisma.$disconnect();
});

process.on("SIGTERM", async () => {
    await prisma.$disconnect();
});

export default prisma;