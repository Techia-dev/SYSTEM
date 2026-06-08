"use client";

import { useState, useMemo, useRef } from "react";
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
import {
  useCandidatePage,
  useCreateCandidate,
  useUpdateCandidate,
  useDeleteCandidate,
  useUploadCv,
} from "@/lib/hooks";
import type { Candidate, CandidateLevel, CreateCandidateDto, UpdateCandidateDto } from "@techia/types";

const LEVELS: { value: CandidateLevel | "all"; label: string }[] = [
  { value: "all", label: "All levels" },
  { value: "junior", label: "Junior" },
  { value: "mid", label: "Mid" },
  { value: "senior", label: "Senior" },
  { value: "lead", label: "Lead" },
];

const PAGE_SIZE = 20;

const emptyCreate: CreateCandidateDto = { name: "", phone: "", email: "", level: "junior" };

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:4000";

async function openCv(url: string) {
  const token = typeof window !== "undefined" ? localStorage.getItem("auth_token") : null;
  const res = await fetch(`${API_URL}${url}`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
  if (!res.ok) return;
  const blob = await res.blob();
  window.open(URL.createObjectURL(blob), "_blank");
}

export default function CandidatesPage() {
  const [page, setPage] = useState(1);
  const { data, isLoading, error, refetch } = useCandidatePage(page, PAGE_SIZE);
  const createMutation = useCreateCandidate();
  const updateMutation = useUpdateCandidate();
  const deleteMutation = useDeleteCandidate();
  const uploadCvMutation = useUploadCv();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const candidates = data?.data ?? [];
  const total = data?.total ?? 0;

  const [levelFilter, setLevelFilter] = useState<CandidateLevel | "all">("all");
  const [search, setSearch] = useState("");

  const [addOpen, setAddOpen] = useState(false);
  const [addForm, setAddForm] = useState<CreateCandidateDto>(emptyCreate);
  const [addFormError, setAddFormError] = useState<string | null>(null);

  const [editTarget, setEditTarget] = useState<Candidate | null>(null);
  const [editForm, setEditForm] = useState<UpdateCandidateDto>({});
  const [editFormError, setEditFormError] = useState<string | null>(null);

  const [deleteTarget, setDeleteTarget] = useState<Candidate | null>(null);

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

  // ── Add ──
  function openAdd() {
    setAddForm(emptyCreate);
    setAddFormError(null);
    setAddOpen(true);
  }

  async function handleAdd() {
    if (!addForm.name.trim() || !addForm.phone.trim()) {
      setAddFormError("Name and phone are required.");
      return;
    }
    try {
      setAddFormError(null);
      await createMutation.mutateAsync({
        name: addForm.name.trim(),
        phone: addForm.phone.trim(),
        email: addForm.email?.trim() || undefined,
        level: addForm.level,
      });
      setAddOpen(false);
    } catch (err) {
      setAddFormError(getErrorMessage(err));
    }
  }

  // ── Edit ──
  function openEdit(c: Candidate) {
    setEditTarget(c);
    setEditForm({
      name: c.name,
      phone: c.phone,
      secondaryPhone: c.secondaryPhone ?? "",
      email: c.email ?? "",
      level: c.level,
      qualification: c.qualification ?? "",
      experience: c.experience ?? "",
    });
    setEditFormError(null);
  }

  async function handleEdit() {
    if (!editTarget) return;
    try {
      setEditFormError(null);
      await updateMutation.mutateAsync({
        id: editTarget.id,
        data: {
          name: editForm.name?.trim() || undefined,
          phone: editForm.phone?.trim() || undefined,
          secondaryPhone: editForm.secondaryPhone?.trim() || null,
          email: editForm.email?.trim() || null,
          level: editForm.level,
          qualification: editForm.qualification?.trim() || null,
          experience: editForm.experience?.trim() || null,
        },
      });
      setEditTarget(null);
    } catch (err) {
      setEditFormError(getErrorMessage(err));
    }
  }

  // ── Delete ──
  async function handleDelete() {
    if (!deleteTarget) return;
    try {
      await deleteMutation.mutateAsync(deleteTarget.id);
      setDeleteTarget(null);
    } catch (err) {
      alert(getErrorMessage(err));
    }
  }

  // ── CV Upload ──
  function triggerCvUpload(candidate: Candidate) {
    setEditTarget(candidate);
    fileInputRef.current?.click();
  }

  async function handleCvFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file || !editTarget) return;

    if (file.type !== "application/pdf") {
      setEditFormError("Only PDF files are allowed.");
      return;
    }

    try {
      setEditFormError(null);
      await uploadCvMutation.mutateAsync({ id: editTarget.id, file });
    } catch (err) {
      setEditFormError(getErrorMessage(err));
    }

    if (fileInputRef.current) fileInputRef.current.value = "";
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
            <Th>Qualification</Th>
            <Th>Experience</Th>
            <Th>CV</Th>
            <Th>Joined</Th>
            <Th></Th>
          </tr>
        </TableHead>

        {isLoading ? (
          <TableSkeleton cols={8} />
        ) : filtered.length === 0 ? (
          <TableEmpty cols={8} message="No candidates found" />
        ) : (
          <TableBody>
            {filtered.map((c) => (
              <Tr key={c.id}>
                <Td><AvatarCell name={c.name} sub={c.email ?? undefined} /></Td>
                <Td>
                  <p>{c.phone}</p>
                  {c.secondaryPhone && (
                    <p className="text-xs text-zinc-400">{c.secondaryPhone}</p>
                  )}
                </Td>
                <Td><LevelBadge level={c.level} /></Td>
                <Td className="text-zinc-500 max-w-[140px] truncate">
                  {c.qualification ?? "—"}
                </Td>
                <Td className="text-zinc-500 max-w-[160px] truncate">
                  {c.experience ?? "—"}
                </Td>
                <Td>
                  {c.cvUrl ? (
                    <div className="flex gap-2 items-center">
                      <button
                        onClick={() => openCv(c.cvUrl!)}
                        className="text-emerald-600 hover:underline text-xs font-medium"
                      >
                        View CV
                      </button>
                      <button
                        onClick={() => updateMutation.mutate({ id: c.id, data: { cvUrl: null } })}
                        className="text-red-400 hover:text-red-600 text-xs"
                      >
                        Remove
                      </button>
                    </div>
                  ) : (
                    <span className="text-xs text-zinc-300">—</span>
                  )}
                </Td>
                <Td className="text-zinc-400">{formatDate(new Date(c.createdAt))}</Td>
                <Td>
                  <div className="flex gap-1">
                    <Button variant="ghost" size="sm" onClick={() => openEdit(c)}>
                      Edit
                    </Button>
                    <Button variant="ghost" size="sm" onClick={() => triggerCvUpload(c)}>
                      CV
                    </Button>
                    <Button variant="ghost" size="sm" onClick={() => setDeleteTarget(c)}>
                      <span className="text-red-500">Delete</span>
                    </Button>
                  </div>
                </Td>
              </Tr>
            ))}
          </TableBody>
        )}

        {total > PAGE_SIZE && (
          <tfoot>
            <tr>
              <td colSpan={8} className="p-0">
                <Pagination page={page} pageSize={PAGE_SIZE} total={total} onPageChange={setPage} />
              </td>
            </tr>
          </tfoot>
        )}
      </Table>

      <input
        ref={fileInputRef}
        type="file"
        accept="application/pdf"
        className="hidden"
        onChange={handleCvFile}
      />

      {/* ── Create Modal ── */}
      <Modal
        open={addOpen}
        onClose={() => setAddOpen(false)}
        title="New candidate"
        description="Fill in the candidate's details."
      >
        <div className="space-y-3">
          <Field label="Full name *">
            <input type="text" value={addForm.name} onChange={(e) => setAddForm({ ...addForm, name: e.target.value })} className={inputCls} />
          </Field>
          <Field label="Phone *">
            <input type="tel" value={addForm.phone} onChange={(e) => setAddForm({ ...addForm, phone: e.target.value })} className={inputCls} />
          </Field>
          <Field label="Email">
            <input type="email" value={addForm.email ?? ""} onChange={(e) => setAddForm({ ...addForm, email: e.target.value })} className={inputCls} />
          </Field>
          <Field label="Level">
            <select value={addForm.level} onChange={(e) => setAddForm({ ...addForm, level: e.target.value as CandidateLevel })} className={inputCls}>
              <option value="junior">Junior</option>
              <option value="mid">Mid</option>
              <option value="senior">Senior</option>
              <option value="lead">Lead</option>
            </select>
          </Field>
          {addFormError && <p className="text-sm text-red-600">{addFormError}</p>}
        </div>
        <ModalFooter
          onCancel={() => setAddOpen(false)}
          onConfirm={handleAdd}
          confirmLabel="Add candidate"
          loading={createMutation.isPending}
        />
      </Modal>

      {/* ── Edit Modal ── */}
      <Modal
        open={!!editTarget && !fileInputRef.current?.value}
        onClose={() => setEditTarget(null)}
        title="Edit candidate"
        description={editTarget?.name ?? ""}
      >
        <div className="space-y-3">
          <Field label="Full name">
            <input type="text" value={editForm.name ?? ""} onChange={(e) => setEditForm({ ...editForm, name: e.target.value })} className={inputCls} />
          </Field>
          <Field label="Phone">
            <input type="tel" value={editForm.phone ?? ""} onChange={(e) => setEditForm({ ...editForm, phone: e.target.value })} className={inputCls} />
          </Field>
          <Field label="Alternative phone">
            <input type="tel" value={editForm.secondaryPhone ?? ""} onChange={(e) => setEditForm({ ...editForm, secondaryPhone: e.target.value })} className={inputCls} placeholder="Optional" />
          </Field>
          <Field label="Email">
            <input type="email" value={editForm.email ?? ""} onChange={(e) => setEditForm({ ...editForm, email: e.target.value })} className={inputCls} />
          </Field>
          <Field label="Level">
            <select value={editForm.level ?? "junior"} onChange={(e) => setEditForm({ ...editForm, level: e.target.value as CandidateLevel })} className={inputCls}>
              <option value="junior">Junior</option>
              <option value="mid">Mid</option>
              <option value="senior">Senior</option>
              <option value="lead">Lead</option>
            </select>
          </Field>
          <Field label="Qualification">
            <input type="text" value={editForm.qualification ?? ""} onChange={(e) => setEditForm({ ...editForm, qualification: e.target.value })} className={inputCls} placeholder="e.g. Bachelor of Computer Science" />
          </Field>
          <Field label="Experience">
            <textarea value={editForm.experience ?? ""} onChange={(e) => setEditForm({ ...editForm, experience: e.target.value })} className={`${inputCls} resize-none h-20`} placeholder="Previous work experience…" />
          </Field>
          {editFormError && <p className="text-sm text-red-600">{editFormError}</p>}
          {uploadCvMutation.isPending && <p className="text-sm text-emerald-600">Uploading CV…</p>}
        </div>
        <ModalFooter
          onCancel={() => setEditTarget(null)}
          onConfirm={handleEdit}
          confirmLabel="Save changes"
          loading={updateMutation.isPending}
        />
      </Modal>

      {/* ── Delete Confirmation Modal ── */}
      <Modal
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        title="Delete candidate"
        size="sm"
        description={deleteTarget?.name ?? ""}
      >
        <p className="text-sm text-zinc-500">
          Are you sure you want to delete <strong>{deleteTarget?.name}</strong>? This action cannot be undone.
        </p>
        <ModalFooter
          onCancel={() => setDeleteTarget(null)}
          onConfirm={handleDelete}
          confirmLabel="Delete"
          confirmVariant="danger"
          loading={deleteMutation.isPending}
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
