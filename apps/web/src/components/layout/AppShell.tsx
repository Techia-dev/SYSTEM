"use client";

import { useEffect, useState } from "react";
import { usePathname, useRouter } from "next/navigation";
import { isAuthenticated, clearAuthToken, authApi } from "@/lib/auth";
import { Sidebar } from "./Sidebar";

export function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname() ?? "/";
  const router = useRouter();
  const isLogin = pathname === "/login";
  const [checking, setChecking] = useState(false);

  useEffect(() => {
    if (isLogin) return;

    if (!isAuthenticated()) {
      router.replace("/login");
      return;
    }

    let cancelled = false;

    async function verify() {
      try {
        setChecking(true);
        await authApi.me();
      } catch {
        if (!cancelled) {
          clearAuthToken();
          const secure = typeof window !== "undefined" && window.location.protocol === "https:" ? "; Secure" : "";
          document.cookie = `auth_token=; path=/; max-age=0; SameSite=Lax${secure}`;
          router.replace("/login");
        }
      } finally {
        if (!cancelled) setChecking(false);
      }
    }

    void verify();
    return () => { cancelled = true; };
  }, [isLogin, router]);

  if (isLogin) {
    return <>{children}</>;
  }

  if (checking) {
    return (
      <div className="h-full flex items-center justify-center bg-zinc-50">
        <div className="flex flex-col items-center gap-3">
          <div className="w-6 h-6 border-2 border-emerald-600 border-t-transparent rounded-full animate-spin" />
          <p className="text-sm text-zinc-500">Verifying session…</p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full flex">
      <Sidebar />
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        {children}
      </div>
    </div>
  );
}
