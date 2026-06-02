import { api } from "@/lib/api";
import type { CreateApplicationDto, UpdateApplicationStatusDto } from "@techia/types";

export const applicationsService = {
    list: () => api.applications.list(),
    create: (data: CreateApplicationDto) => api.applications.create(data),
    updateStatus: (id: string, data: UpdateApplicationStatusDto) =>
        api.applications.updateStatus(id, data),
};