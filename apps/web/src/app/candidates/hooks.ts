"use client";

import { useCallback, useState } from "react";
import { candidatesService } from "./service";
import { getErrorMessage } from "@/lib/utils";
import type { Candidate } from "@techia/types";

export function useCandidates() {
    const [candidates, setCandidates] = useState<Candidate[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    const load = useCallback(async () => {
        try {
            setLoading(true);
            setError(null);

            const data = await candidatesService.list();
            setCandidates(data);
        } catch (err) {
            setError(getErrorMessage(err));
        } finally {
            setLoading(false);
        }
    }, []);

    return { candidates, setCandidates, loading, error, load };
}