import Link from "next/link";

export default function NotFound() {
  return (
    <div className="h-full flex items-center justify-center bg-zinc-50">
      <div className="text-center max-w-md">
        <div className="w-12 h-12 rounded-full bg-zinc-100 flex items-center justify-center mx-auto mb-4">
          <span className="text-xl font-bold text-zinc-400">404</span>
        </div>
        <h2 className="text-lg font-semibold text-zinc-900 mb-1">Page not found</h2>
        <p className="text-sm text-zinc-500 mb-6">The page you&apos;re looking for doesn&apos;t exist.</p>
        <Link
          href="/"
          className="px-4 py-2 text-sm font-medium rounded-lg bg-emerald-600 text-white hover:bg-emerald-700 transition-colors"
        >
          Go home
        </Link>
      </div>
    </div>
  );
}
