// ============================================================
// Sidebar — شريط التنقل الجانبي
// ============================================================

"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";

// ── Nav items ─────────────────────────────────────────────────

const navItems = [
    {
        group: "Overview",
        items: [
            { href: "/", label: "Dashboard", icon: <GridIcon /> },
        ],
    },
    {
        group: "Recruitment",
        items: [
            { href: "/candidates", label: "Candidates", icon: <UserIcon /> },
            { href: "/applications", label: "Applications", icon: <FileIcon /> },
            { href: "/offers", label: "Offers", icon: <BriefcaseIcon /> },
        ],
    },
    {
        group: "Finance",
        items: [
            { href: "/commissions", label: "Commissions", icon: <CashIcon /> },
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
                    <svg className="w-4 h-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
                        <path strokeLinecap="round" strokeLinejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0" />
                    </svg>
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
        router.replace("/login");
    }

    return (
        <button
            onClick={handleLogout}
            className="flex items-center gap-2.5 px-2.5 py-1.5 rounded-lg text-sm text-zinc-500 hover:bg-red-50 hover:text-red-600 w-full transition-colors"
        >
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.75}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15m3 0l3-3m0 0l-3-3m3 3H9" />
            </svg>
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

// ── Icons (inline SVGs — لا dependency خارجية) ───────────────

function GridIcon() {
    return (
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.75}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 6A2.25 2.25 0 016 3.75h2.25A2.25 2.25 0 0110.5 6v2.25a2.25 2.25 0 01-2.25 2.25H6a2.25 2.25 0 01-2.25-2.25V6zM3.75 15.75A2.25 2.25 0 016 13.5h2.25a2.25 2.25 0 012.25 2.25V18a2.25 2.25 0 01-2.25 2.25H6A2.25 2.25 0 013.75 18v-2.25zM13.5 6a2.25 2.25 0 012.25-2.25H18A2.25 2.25 0 0120.25 6v2.25A2.25 2.25 0 0118 10.5h-2.25a2.25 2.25 0 01-2.25-2.25V6zM13.5 15.75a2.25 2.25 0 012.25-2.25H18a2.25 2.25 0 012.25 2.25V18A2.25 2.25 0 0118 20.25h-2.25A2.25 2.25 0 0113.5 18v-2.25z" />
        </svg>
    );
}

function UserIcon() {
    return (
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.75}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
        </svg>
    );
}

function FileIcon() {
    return (
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.75}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z" />
        </svg>
    );
}

function BriefcaseIcon() {
    return (
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.75}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M20.25 14.15v4.25c0 1.094-.787 2.036-1.872 2.18-2.087.277-4.216.42-6.378.42s-4.291-.143-6.378-.42c-1.085-.144-1.872-1.086-1.872-2.18v-4.25m16.5 0a2.18 2.18 0 00.75-1.661V8.706c0-1.081-.768-2.015-1.837-2.175a48.114 48.114 0 00-3.413-.387m4.5 8.006c-.194.165-.42.295-.673.38A23.978 23.978 0 0112 15.75c-2.648 0-5.195-.429-7.577-1.22a2.016 2.016 0 01-.673-.38m0 0A2.18 2.18 0 013 12.489V8.706c0-1.081.768-2.015 1.837-2.175a48.111 48.111 0 013.413-.387m7.5 0V5.25A2.25 2.25 0 0013.5 3h-3a2.25 2.25 0 00-2.25 2.25v.894m7.5 0a48.667 48.667 0 00-7.5 0" />
        </svg>
    );
}

function CashIcon() {
    return (
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.75}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M2.25 18.75a60.07 60.07 0 0115.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 013 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 00-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 01-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 003 15h-.75M15 10.5a3 3 0 11-6 0 3 3 0 016 0zm3 0h.008v.008H18V10.5zm-12 0h.008v.008H6V10.5z" />
        </svg>
    );
}
