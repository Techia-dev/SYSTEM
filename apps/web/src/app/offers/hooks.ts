"use client";

import { useCallback, useState } from "react";
import { offersService } from "./service";
import { getErrorMessage } from "@/lib/utils";
import type { Offer } from "@techia/types";

export function useOffers() {
    const [offers, setOffers] = useState<Offer[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    const load = useCallback(async () => {
        try {
            setLoading(true);
            setError(null);

            const res = await offersService.list();
            setOffers(res.data);
        } catch (err) {
            setError(getErrorMessage(err));
        } finally {
            setLoading(false);
        }
    }, []);

    return { offers, setOffers, loading, error, load };
}