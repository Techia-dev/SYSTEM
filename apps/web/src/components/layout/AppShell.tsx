"use client";

import { useEffect } from "react";
import { usePathname, useRouter } from "next/navigation";
import { isAuthenticated } from "@/lib/api";
import { Sidebar } from "./Sidebar";

export function AppShell({ children }: { children: React.ReactNode }) {
    const pathname = usePathname() ?? "/";
    const router = useRouter();
    const isLogin = pathname === "/login";

    useEffect(() => {
        if (!isLogin && !isAuthenticated()) {
            router.replace("/login");
        }
    }, [isLogin, router]);

    if (isLogin) {
        return <>{children}</>;
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
