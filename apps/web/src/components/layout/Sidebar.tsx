// ============================================================
// Sidebar — شريط التنقل الجانبي
// ============================================================

"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  LayoutDashboard, Users, FileText, Briefcase, DollarSign, LogOut,
} from "lucide-react";

// ── Nav items ─────────────────────────────────────────────────

const navItems = [
    {
        group: "Overview",
        items: [
            { href: "/", label: "Dashboard", icon: <LayoutDashboard className="w-4 h-4" /> },
        ],
    },
    {
        group: "Recruitment",
        items: [
            { href: "/candidates", label: "Candidates", icon: <Users className="w-4 h-4" /> },
            { href: "/applications", label: "Applications", icon: <FileText className="w-4 h-4" /> },
            { href: "/offers", label: "Offers", icon: <Briefcase className="w-4 h-4" /> },
        ],
    },
    {
        group: "Finance",
        items: [
            { href: "/commissions", label: "Commissions", icon: <DollarSign className="w-4 h-4" /> },
        ],
    },
] as const;

// ── Sidebar ───────────────────────────────────────────────────

export function Sidebar() {
    const pathname = usePathname() ?? "/";

    return (
        <aside className="w-55 shrink-0 bg-white border-r border-zinc-200 flex flex-col h-screen sticky top-0">
            {/* Logo */}
            <div className="h-14 flex items-center gap-2.5 px-5 border-b border-zinc-100">
                <div className="w-7 h-7 rounded-md bg-emerald-600 flex items-center justify-center shrink-0">
                    <Users className="w-4 h-4 text-white" />
                </div>
                <div>
                    <p className="text-sm font-semibold text-zinc-900 leading-none">Techia</p>
                    <p className="text-[11px] text-zinc-400 mt-0.5">ATS System</p>
                </div>
            </div>

            {/* Nav */}
            <nav className="flex-1 overflow-y-auto px-3 py-3 space-y-5">
                {navItems.map((group) => (
                    <div key={group.group}>
                        <p className="px-2 mb-1 text-[10px] font-semibold text-zinc-400 uppercase tracking-widest">
                            {group.group}
                        </p>
                        <ul className="space-y-0.5">
                            {group.items.map((item) => {
                                const active =
                                    item.href === "/"
                                        ? pathname === "/"
                                        : pathname.startsWith(item.href);
                                return (
                                    <li key={item.href}>
                                        <Link
                                            href={item.href}
                                            className={[
                                                "flex items-center gap-2.5 px-2.5 py-1.5 rounded-lg",
                                                "text-sm transition-colors duration-100",
                                                active
                                                    ? "bg-emerald-50 text-emerald-700 font-medium"
                                                    : "text-zinc-600 hover:bg-zinc-50 hover:text-zinc-800",
                                            ].join(" ")}
                                            aria-current={active ? "page" : undefined}
                                        >
                                            <span
                                                className={active ? "text-emerald-600" : "text-zinc-400"}
                                                aria-hidden="true"
                                            >
                                                {item.icon}
                                            </span>
                                            {item.label}
                                        </Link>
                                    </li>
                                );
                            })}
                        </ul>
                    </div>
                ))}
            </nav>

            {/* Logout */}
            <div className="px-3 py-3 border-t border-zinc-100">
                <LogoutButton />
            </div>
        </aside>
    );
}

function LogoutButton() {
    const router = useRouter();

    function handleLogout() {
        localStorage.removeItem("auth_token");
        const secure = typeof window !== "undefined" && window.location.protocol === "https:" ? "; Secure" : "";
        document.cookie = `auth_token=; path=/; max-age=0; SameSite=Lax${secure}`;
        router.replace("/login");
    }

    return (
        <button
            onClick={handleLogout}
            className="flex items-center gap-2.5 px-2.5 py-1.5 rounded-lg text-sm text-zinc-500 hover:bg-red-50 hover:text-red-600 w-full transition-colors"
        >
            <LogOut className="w-4 h-4" />
            Sign out
        </button>
    );
}

// ── Page shell (Header + content area) ───────────────────────

interface PageShellProps {
    title: string;
    action?: React.ReactNode;
    children: React.ReactNode;
}

export function PageShell({ title, action, children }: PageShellProps) {
    return (
        <div className="flex flex-col flex-1 min-h-0">
            {/* Topbar */}
            <header className="h-14 shrink-0 flex items-center justify-between px-6 bg-white border-b border-zinc-200">
                <h1 className="text-base font-semibold text-zinc-900">{title}</h1>
                {action && <div className="flex items-center gap-2">{action}</div>}
            </header>

            {/* Content */}
            <main className="flex-1 overflow-y-auto p-6 bg-zinc-50">
                {children}
            </main>
        </div>
    );
}


