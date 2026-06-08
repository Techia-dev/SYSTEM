"use client";

import { useCallback, useState } from "react";
import { applicationsService } from "./service";
import { getErrorMessage } from "@/lib/utils";
import type { ApplicationWithRelations } from "@techia/types";

export function useApplications() {
    const [applications, setApplications] = useState<
        ApplicationWithRelations[]
    >([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    const load = useCallback(async () => {
        try {
            setLoading(true);
            setError(null);

            const res = await applicationsService.list();
            setApplications(res.data);
        } catch (err) {
            setError(getErrorMessage(err));
        } finally {
            setLoading(false);
        }
    }, []);

    return { applications, setApplications, loading, error, load };
}