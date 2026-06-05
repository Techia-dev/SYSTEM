import bcrypt from "bcryptjs";
import { prisma } from "./client";

async function main() {
    const adminEmail =
        process.env.SEED_ADMIN_EMAIL ?? "admin@techia.com";

    const adminPassword =
        process.env.SEED_ADMIN_PASSWORD ?? "ChangeMe123!";

    const existing = await prisma.user.findUnique({
        where: {
            email: adminEmail,
        },
    });

    if (existing) {
        console.log("ℹ️ Admin user already exists");
        return;
    }

    const passwordHash = await bcrypt.hash(
        adminPassword,
        12
    );

    await prisma.user.create({
        data: {
            email: adminEmail,
            password: passwordHash,
            name: "Techia Admin",
            role: "admin",
        },
    });

    console.log("✅ Admin user created");
}

main()
    .catch((error) => {
        console.error("Seed failed:", error);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });