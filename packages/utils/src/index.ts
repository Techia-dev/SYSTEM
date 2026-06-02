export function formatDate(date: Date | string): string {
    const d = typeof date === "string" ? new Date(date) : date;
    return new Intl.DateTimeFormat("en-EG", {
        year: "numeric",
        month: "short",
        day: "numeric",
    }).format(d);
}