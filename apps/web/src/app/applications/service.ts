import { sdk } from "@/lib/sdk";
import type { CreateApplicationDto, UpdateApplicationStatusDto } from "@techia/types";

export const applicationsService = {
    list: () => sdk.applications.list(),
    create: (data: CreateApplicationDto) => sdk.applications.create(data),
    updateStatus: (id: string, data: UpdateApplicationStatusDto) =>
        sdk.applications.updateStatus(id, data),
};