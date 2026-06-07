import { TechiaSdk } from "@techia/sdk";

const baseURL =
    process.env.NEXT_PUBLIC_API_URL ??
    "http://localhost:4000";

export const sdk = new TechiaSdk({
    baseURL,
});