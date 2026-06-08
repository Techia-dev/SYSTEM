"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { authApi, setAuthToken, isAuthenticated } from "@/lib/auth";
import { sdk } from "@/lib/sdk";
import { getErrorMessage } from "@/lib/utils";

export default function LoginPage() {
    const router = useRouter();
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        if (isAuthenticated()) {
            router.replace("/");
        }
    }, [router]);

    async function handleSubmit(e: React.FormEvent) {
        e.preventDefault();
        setError(null);

        if (!email.trim() || !password) {
            setError("Email and password are required.");
            return;
        }

        try {
            setLoading(true);

            const res = await authApi.login({
                email: email.trim(),
                password,
            });

            setAuthToken(res.token);
            sdk.setAuthToken(res.token);
            document.cookie = `auth_token=${res.token}; path=/; max-age=${60 * 60 * 24}; SameSite=Lax`;

            router.replace("/");
        } catch (err) {
            setError(getErrorMessage(err));
        } finally {
            setLoading(false);
        }
    }

    return (
        <div className="h-full flex items-center justify-center bg-zinc-50">
            <div className="w-full max-w-sm mx-auto">
                <div className="bg-white rounded-xl border border-zinc-200 p-8 shadow-sm">
                    <div className="mb-8 text-center">
                        <div className="w-10 h-10 rounded-lg bg-emerald-600 flex items-center justify-center mx-auto mb-3">
                            <svg
                                className="w-5 h-5 text-white"
                                fill="none"
                                viewBox="0 0 24 24"
                                stroke="currentColor"
                                strokeWidth={2.5}
                            >
                                <path
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                    d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0"
                                />
                            </svg>
                        </div>

                        <h1 className="text-lg font-semibold text-zinc-900">
                            Techia ATS
                        </h1>

                        <p className="text-sm text-zinc-500 mt-1">
                            Sign in to your account
                        </p>
                    </div>

                    {error && (
                        <div className="mb-4 px-3 py-2.5 rounded-lg bg-red-50 border border-red-200 text-sm text-red-700">
                            {error}
                        </div>
                    )}

                    <form onSubmit={handleSubmit} className="space-y-4">
                        <div>
                            <label className="text-xs font-medium text-zinc-500">
                                Email
                            </label>

                            <input
                                type="email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder="admin@techia.com"
                                className="w-full h-9 px-3 text-sm rounded-lg border border-zinc-200 bg-white text-zinc-800 placeholder:text-zinc-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 mt-1"
                                autoComplete="email"
                            />
                        </div>

                        <div>
                            <label className="text-xs font-medium text-zinc-500">
                                Password
                            </label>

                            <input
                                type="password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                placeholder="Enter your password"
                                className="w-full h-9 px-3 text-sm rounded-lg border border-zinc-200 bg-white text-zinc-800 placeholder:text-zinc-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 mt-1"
                                autoComplete="current-password"
                            />
                        </div>

                        <button
                            type="submit"
                            disabled={loading}
                            className="w-full h-9 text-sm font-medium rounded-lg bg-emerald-600 text-white hover:bg-emerald-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                        >
                            {loading ? "Signing in..." : "Sign in"}
                        </button>
                    </form>

                    <p className="mt-6 text-center text-xs text-zinc-400">
                        Techia ATS · v1.0.0
                    </p>
                </div>
            </div>
        </div>
    );
}