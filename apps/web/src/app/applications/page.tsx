"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { PageShell } from "@/components/layout/Sidebar";
import {
  Table,
  TableHead,
  Th,
  TableBody,
  Tr,
  Td,
  TableSkeleton,
  TableEmpty,
  AvatarCell,
} from "@/components/ui/Table";
import { ApplicationBadge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Modal, ModalFooter } from "@/components/ui/Modal";
import { api } from "@/lib/api";
import { formatDate } from "@techia/utils";
import { getErrorMessage } from "@/lib/utils";
import type {
  ApplicationWithRelations,
  CreateApplicationDto,
  ApplicationStatus,
  Candidate,
  Offer,
} from "@techia/types";

const STATUSES: { value: ApplicationStatus | "all"; label: string }[] = [
  { value: "all", label: "All statuses" },
  { value: "applied", label: "Applied" },
  { value: "interview", label: "Interview" },
  { value: "accepted", label: "Accepted" },
  { value: "rejected", label: "Rejected" },
];

export default function ApplicationsPage() {
  const [applications, setApplications] = useState<ApplicationWithRelations[]>([]);
  const [candidates, setCandidates] = useState<Candidate[]>([]);
  const [offers, setOffers] = useState<Offer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [statusFilter, setStatusFilter] = useState<ApplicationStatus | "all">("all");
  const [search, setSearch] = useState("");

  // add modal
  const [addOpen, setAddOpen] = useState(false);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [form, setForm] = useState<CreateApplicationDto>({
    candidateId: "",
    offerId: "",
    source: "",
    assignedTo: "",
  });

  // status modal
  const [statusOpen, setStatusOpen] = useState(false);
  const [statusTarget, setStatusTarget] = useState<ApplicationWithRelations | null>(null);
  const [newStatus, setNewStatus] = useState<ApplicationStatus>("applied");
  const [statusSaving, setStatusSaving] = useState(false);
  const [statusError, setStatusError] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      setError(null);

      const [apps, cands, offs] = await Promise.all([
        api.applications.list(),
        api.candidates.list(),
        api.offers.list(),
      ]);

      setApplications(apps);
      setCandidates(cands);
      setOffers(offs.filter((o) => o.isActive));
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const id = window.setTimeout(() => {
      void load();
    }, 0);

    return () => window.clearTimeout(id);
  }, [load]);

  const filtered = useMemo(() => {
    return applications.filter((a) => {
      const matchStatus = statusFilter === "all" || a.status === statusFilter;
      const term = search.trim().toLowerCase();

      const matchSearch =
        term === "" ||
        a.candidate.name.toLowerCase().includes(term) ||
        a.offer.title.toLowerCase().includes(term);

      return matchStatus && matchSearch;
    });
  }, [applications, search, statusFilter]);

  function openAdd() {
    setForm({ candidateId: "", offerId: "", source: "", assignedTo: "" });
    setFormError(null);
    setAddOpen(true);
  }

  async function handleAdd() {
    if (!form.candidateId || !form.offerId) {
      setFormError("Candidate and offer are required.");
      return;
    }

    try {
      setSaving(true);
      setFormError(null);

      await api.applications.create({
        candidateId: form.candidateId,
        offerId: form.offerId,
        source: form.source?.trim() || undefined,
        assignedTo: form.assignedTo?.trim() || undefined,
      });

      setAddOpen(false);
      await load();
    } catch (err) {
      setFormError(getErrorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  function openStatus(app: ApplicationWithRelations) {
    setStatusTarget(app);
    setNewStatus(app.status);
    setStatusError(null);
    setStatusOpen(true);
  }

  async function handleStatusUpdate() {
    if (!statusTarget) return;

    try {
      setStatusSaving(true);
      setStatusError(null);

      await api.applications.updateStatus(statusTarget.id, { status: newStatus });

      setStatusOpen(false);
      await load();
    } catch (err) {
      setStatusError(getErrorMessage(err));
    } finally {
      setStatusSaving(false);
    }
  }

  return (
    <PageShell
      title="Applications"
      action={
        <Button variant="primary" onClick={openAdd} icon={<PlusIcon />}>
          New application
        </Button>
      }
    >
      <div className="flex gap-2 mb-4">
        <input
          type="text"
          placeholder="Search candidate or offer…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="h-8 px-3 text-sm rounded-lg border border-zinc-200 bg-white text-zinc-800 placeholder:text-zinc-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 w-64"
        />
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value as ApplicationStatus | "all")}
          className="h-8 px-2.5 text-sm rounded-lg border border-zinc-200 bg-white text-zinc-700 focus:outline-none focus:ring-2 focus:ring-emerald-500"
        >
          {STATUSES.map((s) => (
            <option key={s.value} value={s.value}>
              {s.label}
            </option>
          ))}
        </select>
      </div>

      {error && (
        <div className="mb-4 px-4 py-3 rounded-lg bg-red-50 border border-red-200 text-sm text-red-700 flex justify-between">
          {error}
          <button onClick={load} className="underline">
            Retry
          </button>
        </div>
      )}

      <Table>
        <TableHead>
          <tr>
            <Th>Candidate</Th>
            <Th>Offer</Th>
            <Th>Status</Th>
            <Th>Source</Th>
            <Th>Assigned to</Th>
            <Th>Date</Th>
            <Th></Th>
          </tr>
        </TableHead>

        {loading ? (
          <TableSkeleton cols={7} />
        ) : filtered.length === 0 ? (
          <TableEmpty cols={7} message="No applications found" icon="📄" />
        ) : (
          <TableBody>
            {filtered.map((a) => (
              <Tr key={a.id}>
                <Td>
                  <AvatarCell name={a.candidate.name} sub={a.candidate.level} />
                </Td>
                <Td>
                  <div>
                    <p className="font-medium text-zinc-800">{a.offer.title}</p>
                    {a.offer.company && (
                      <p className="text-xs text-zinc-400">{a.offer.company}</p>
                    )}
                  </div>
                </Td>
                <Td>
                  <ApplicationBadge status={a.status} />
                </Td>
                <Td className="text-zinc-400">{a.source ?? "—"}</Td>
                <Td className="text-zinc-400">{a.assignedTo ?? "—"}</Td>
                <Td className="text-zinc-400">{formatDate(new Date(a.createdAt))}</Td>
                <Td>
                  <Button variant="ghost" size="sm" onClick={() => openStatus(a)}>
                    Update status
                  </Button>
                </Td>
              </Tr>
            ))}
          </TableBody>
        )}
      </Table>

      {/* Add Modal */}
      <Modal
        open={addOpen}
        onClose={() => setAddOpen(false)}
        title="New application"
        description="Link a candidate to an offer."
      >
        <div className="space-y-3">
          <Field label="Candidate *">
            <select
              value={form.candidateId}
              onChange={(e) => setForm({ ...form, candidateId: e.target.value })}
              className={inputCls}
            >
              <option value="">Select candidate…</option>
              {candidates.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name} — {c.level}
                </option>
              ))}
            </select>
          </Field>

          <Field label="Offer *">
            <select
              value={form.offerId}
              onChange={(e) => setForm({ ...form, offerId: e.target.value })}
              className={inputCls}
            >
              <option value="">Select offer…</option>
              {offers.map((o) => (
                <option key={o.id} value={o.id}>
                  {o.title}
                  {o.company ? ` — ${o.company}` : ""}
                </option>
              ))}
            </select>
          </Field>

          <Field label="Source">
            <input
              type="text"
              placeholder="LinkedIn, Referral…"
              value={form.source}
              onChange={(e) => setForm({ ...form, source: e.target.value })}
              className={inputCls}
            />
          </Field>

          <Field label="Assigned to">
            <input
              type="text"
              placeholder="Recruiter name"
              value={form.assignedTo}
              onChange={(e) => setForm({ ...form, assignedTo: e.target.value })}
              className={inputCls}
            />
          </Field>

          {formError && <p className="text-sm text-red-600">{formError}</p>}
        </div>

        <ModalFooter
          onCancel={() => setAddOpen(false)}
          onConfirm={handleAdd}
          confirmLabel="Create application"
          loading={saving}
        />
      </Modal>

      {/* Status Modal */}
      <Modal
        open={statusOpen}
        onClose={() => setStatusOpen(false)}
        title="Update status"
        size="sm"
        description={statusTarget ? `${statusTarget.candidate.name} — ${statusTarget.offer.title}` : ""}
      >
        <div className="space-y-3">
          <Field label="New status">
            <select
              value={newStatus}
              onChange={(e) => setNewStatus(e.target.value as ApplicationStatus)}
              className={inputCls}
            >
              <option value="applied">Applied</option>
              <option value="interview">Interview</option>
              <option value="accepted">Accepted</option>
              <option value="rejected">Rejected</option>
            </select>
          </Field>

          {newStatus === "accepted" && (
            <p className="text-xs text-emerald-700 bg-emerald-50 border border-emerald-200 rounded-lg px-3 py-2">
              A commission will be created automatically.
            </p>
          )}

          {statusError && <p className="text-sm text-red-600">{statusError}</p>}
        </div>

        <ModalFooter
          onCancel={() => setStatusOpen(false)}
          onConfirm={handleStatusUpdate}
          confirmLabel="Update"
          loading={statusSaving}
        />
      </Modal>
    </PageShell>
  );
}

const inputCls =
  "w-full h-9 px-3 text-sm rounded-lg border border-zinc-200 bg-white " +
  "text-zinc-800 focus:outline-none focus:ring-2 focus:ring-emerald-500";

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