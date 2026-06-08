import { FastifyPluginAsync } from "fastify";
import { createWriteStream, existsSync, mkdirSync, readFileSync } from "fs";
import { join, extname } from "path";
import { pipeline } from "stream/promises";
import { randomUUID } from "crypto";
import { CandidatesController } from "./candidates.controller";
import { CandidatesService } from "./candidates.service";
import { CandidatesRepository } from "./candidates.repository";
import { NotFoundError } from "../../shared/error";
import { successResponse } from "../../shared/response";
import type {
    CreateCandidateDto,
    UpdateCandidateDto,
    ListCandidatesQueryDto,
} from "@techia/types";

const UPLOADS_DIR = join(__dirname, "..", "..", "..", "uploads", "cvs");

function ensureUploadsDir() {
    if (!existsSync(UPLOADS_DIR)) {
        mkdirSync(UPLOADS_DIR, { recursive: true });
    }
}

const routes: FastifyPluginAsync = async (fastify) => {
    fastify.addHook("onRequest", fastify.requirePermission("candidates:read"));

    fastify.get<{
        Querystring: ListCandidatesQueryDto;
    }>("/", CandidatesController.list);

    fastify.get<{ Params: { id: string } }>(
        "/:id",
        CandidatesController.getById
    );

    fastify.post<{
        Body: CreateCandidateDto;
    }>(
        "/",
        { preHandler: [fastify.requirePermission("candidates:write")] },
        CandidatesController.create
    );

    fastify.put<{
        Params: { id: string };
        Body: UpdateCandidateDto;
    }>(
        "/:id",
        { preHandler: [fastify.requirePermission("candidates:write")] },
        CandidatesController.update
    );

    fastify.delete<{
        Params: { id: string };
    }>(
        "/:id",
        { preHandler: [fastify.requirePermission("candidates:write")] },
        CandidatesController.delete
    );

    // ── CV Upload ─────────────────────────────────────────
    fastify.post<{ Params: { id: string } }>(
        "/:id/cv",
        { preHandler: [fastify.requirePermission("candidates:write")] },
        async (request, reply) => {
            const { id } = request.params;
            const service = new CandidatesService(new CandidatesRepository());

            const candidate = await service.getById(id);
            if (!candidate) {
                throw new NotFoundError("Candidate", id);
            }

            ensureUploadsDir();

            const data = await request.file();
            if (!data) {
                return reply.status(400).send({
                    success: false,
                    error: { message: "No file uploaded", code: "MISSING_FILE" },
                });
            }

            const ext = extname(data.filename) || ".pdf";
            const filename = `${id}-${randomUUID()}${ext}`;
            const filepath = join(UPLOADS_DIR, filename);

            await pipeline(data.file, createWriteStream(filepath));

            const cvUrl = `/api/candidates/${id}/cv/download/${filename}`;
            await service.update(id, { cvUrl });

            return reply.send(successResponse({ cvUrl }));
        }
    );

    // ── CV Download ────────────────────────────────────────
    fastify.get<{ Params: { id: string; filename: string } }>(
        "/:id/cv/download/:filename",
        async (request, reply) => {
            const { filename } = request.params;
            const filepath = join(UPLOADS_DIR, filename);

            if (!existsSync(filepath)) {
                throw new NotFoundError("CV file", filename);
            }

            const buffer = readFileSync(filepath);
            return reply.type("application/pdf").send(buffer);
        }
    );
};

export default routes;
