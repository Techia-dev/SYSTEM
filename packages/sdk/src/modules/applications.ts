import type {
    ApplicationWithRelations,
    ApplicationFull,
    CreateApplicationDto,
    UpdateApplicationStatusDto,
    UpdateStatusResponse,
    PaginatedResponse,
} from "@techia/types";

import type { HttpClient } from "../client";

export class ApplicationsResource {
    constructor(private client: HttpClient) { }

    list(): Promise<PaginatedResponse<ApplicationWithRelations>> {
        return this.client.get("/applications");
    }

    getById(id: string): Promise<ApplicationFull> {
        return this.client.get(`/applications/${id}`);
    }

    create(data: CreateApplicationDto) {
        return this.client.post("/applications", data);
    }

    updateStatus(
        id: string,
        data: UpdateApplicationStatusDto
    ): Promise<UpdateStatusResponse> {
        return this.client.put(`/applications/${id}/status`, data);
    }
}