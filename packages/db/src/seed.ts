import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
    const adminEmail = "admin@techia.com";
    const existing = await prisma.user.findUnique({ where: { email: adminEmail } });

    if (!existing) {
        const password = await bcrypt.hash("admin123", 10);
        await prisma.user.create({
            data: {
                email: adminEmail,
                password,
                name: "Techia Admin",
                role: "admin",
            },
        });
        console.log("✅ Admin user created (admin@techia.com / admin123)");
    } else {
        console.log("ℹ️  Admin user already exists");
    }
}

main()
    .catch((e) => {
        console.error("Seed failed:", e);
        process.exit(1);
    })
    .finally(() => prisma.$disconnect());
