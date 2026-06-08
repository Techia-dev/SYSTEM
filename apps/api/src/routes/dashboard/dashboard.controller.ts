import type { FastifyReply, FastifyRequest } from "fastify";
import { DashboardService } from "./dashboard.service";
import { successResponse } from "../../shared/response";

const service = new DashboardService();

export class DashboardController {
    static async stats(
        _request: FastifyRequest,
        reply: FastifyReply
    ) {
        const result = await service.getStats();
        return reply.send(successResponse(result));
    }

    static async analytics(
        _request: FastifyRequest,
        reply: FastifyReply
    ) {
        const result = await service.getAnalytics();
        return reply.send(successResponse(result));
    }
}
