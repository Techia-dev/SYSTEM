"use client";

import { useState, useMemo } from "react";
import { PageShell } from "@/components/layout/Sidebar";
import {
  Table, TableHead, Th, TableBody, Tr, Td,
  TableSkeleton, TableEmpty, AvatarCell,
} from "@/components/ui/Table";
import { LevelBadge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Modal, ModalFooter } from "@/components/ui/Modal";
import { Pagination } from "@/components/ui/Pagination";
import { formatDate } from "@techia/utils";
import { getErrorMessage } from "@/lib/utils";
import { useCandidatePage, useCreateCandidate } from "@/lib/hooks";
import type { CandidateLevel, CreateCandidateDto } from "@techia/types";

const LEVELS: { value: CandidateLevel | "all"; label: string }[] = [
  { value: "all", label: "All levels" },
  { value: "junior", label: "Junior" },
  { value: "mid", label: "Mid" },
  { value: "senior", label: "Senior" },
  { value: "lead", label: "Lead" },
];

const PAGE_SIZE = 20;

export default function CandidatesPage() {
  const [page, setPage] = useState(1);
  const { data, isLoading, error, refetch } = useCandidatePage(page, PAGE_SIZE);
  const createMutation = useCreateCandidate();

  const candidates = data?.data ?? [];
  const total = data?.total ?? 0;

  const [levelFilter, setLevelFilter] = useState<CandidateLevel | "all">("all");
  const [search, setSearch] = useState("");

  const [addOpen, setAddOpen] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [form, setForm] = useState<CreateCandidateDto>({
    name: "", phone: "", email: "", level: "junior",
  });

  const filtered = useMemo(() => {
    const term = search.trim().toLowerCase();
    return candidates.filter((c) => {
      const matchLevel = levelFilter === "all" || c.level === levelFilter;
      const matchSearch =
        term === "" ||
        c.name.toLowerCase().includes(term) ||
        c.phone.includes(term) ||
        (c.email ?? "").toLowerCase().includes(term);
      return matchLevel && matchSearch;
    });
  }, [candidates, levelFilter, search]);

  function openAdd() {
    setForm({ name: "", phone: "", email: "", level: "junior" });
    setFormError(null);
    setAddOpen(true);
  }

  async function handleAdd() {
    if (!form.name.trim() || !form.phone.trim()) {
      setFormError("Name and phone are required.");
      return;
    }
    try {
      setFormError(null);
      await createMutation.mutateAsync({
        name: form.name.trim(),
        phone: form.phone.trim(),
        email: form.email?.trim() || undefined,
        level: form.level,
      });
      setAddOpen(false);
    } catch (err) {
      setFormError(getErrorMessage(err));
    }
  }

  return (
    <PageShell
      title="Candidates"
      action={
        <Button variant="primary" onClick={openAdd} icon={<PlusIcon />}>
          New candidate
        </Button>
      }
    >
      <div className="flex gap-2 mb-4">
        <input
          type="text"
          placeholder="Search name, phone, email…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="h-8 px-3 text-sm rounded-lg border border-zinc-200 bg-white text-zinc-800 placeholder:text-zinc-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 w-64"
        />
        <select
          value={levelFilter}
          onChange={(e) => setLevelFilter(e.target.value as CandidateLevel | "all")}
          className="h-8 px-2.5 text-sm rounded-lg border border-zinc-200 bg-white text-zinc-700 focus:outline-none focus:ring-2 focus:ring-emerald-500"
        >
          {LEVELS.map((l) => (
            <option key={l.value} value={l.value}>{l.label}</option>
          ))}
        </select>
      </div>

      {error && (
        <div className="mb-4 px-4 py-3 rounded-lg bg-red-50 border border-red-200 text-sm text-red-700 flex justify-between">
          {getErrorMessage(error)}
          <button onClick={() => refetch()} className="underline">Retry</button>
        </div>
      )}

      <Table>
        <TableHead>
          <tr>
            <Th>Candidate</Th>
            <Th>Phone</Th>
            <Th>Level</Th>
            <Th>Email</Th>
            <Th>Joined</Th>
          </tr>
        </TableHead>

        {isLoading ? (
          <TableSkeleton cols={5} />
        ) : filtered.length === 0 ? (
          <TableEmpty cols={5} message="No candidates found" />
        ) : (
          <TableBody>
            {filtered.map((c) => (
              <Tr key={c.id}>
                <Td><AvatarCell name={c.name} /></Td>
                <Td>{c.phone}</Td>
                <Td><LevelBadge level={c.level} /></Td>
                <Td className="text-zinc-400">{c.email ?? "—"}</Td>
                <Td className="text-zinc-400">{formatDate(new Date(c.createdAt))}</Td>
              </Tr>
            ))}
          </TableBody>
        )}

        {total > PAGE_SIZE && (
          <tfoot>
            <tr>
              <td colSpan={5} className="p-0">
                <Pagination page={page} pageSize={PAGE_SIZE} total={total} onPageChange={setPage} />
              </td>
            </tr>
          </tfoot>
        )}
      </Table>

      <Modal
        open={addOpen}
        onClose={() => setAddOpen(false)}
        title="New candidate"
        description="Fill in the candidate's details."
      >
        <div className="space-y-3">
          <Field label="Full name *">
            <input type="text" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} className={inputCls} />
          </Field>
          <Field label="Phone *">
            <input type="tel" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} className={inputCls} />
          </Field>
          <Field label="Email">
            <input type="email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} className={inputCls} />
          </Field>
          <Field label="Level">
            <select value={form.level} onChange={(e) => setForm({ ...form, level: e.target.value as CandidateLevel })} className={inputCls}>
              <option value="junior">Junior</option>
              <option value="mid">Mid</option>
              <option value="senior">Senior</option>
              <option value="lead">Lead</option>
            </select>
          </Field>
          {formError && <p className="text-sm text-red-600">{formError}</p>}
        </div>
        <ModalFooter
          onCancel={() => setAddOpen(false)}
          onConfirm={handleAdd}
          confirmLabel="Add candidate"
          loading={createMutation.isPending}
        />
      </Modal>
    </PageShell>
  );
}

const inputCls = "w-full h-9 px-3 text-sm rounded-lg border border-zinc-200 bg-white text-zinc-800 focus:outline-none focus:ring-2 focus:ring-emerald-500";

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-1">
      <label className="text-xs font-medium text-zinc-500">{label}</label>
      {children}
    </div>
  );
}

function PlusIcon() {
  return (
    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
    </svg>
  );
}
