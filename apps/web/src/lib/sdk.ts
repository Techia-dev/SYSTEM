import { TechiaSdk } from "@techia/sdk";

export const sdk = new TechiaSdk({
    baseURL:
        process.env.NEXT_PUBLIC_API_URL ??
        "http://localhost:4000",
});