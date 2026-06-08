"use client";

import { useState, useMemo } from "react";
import { PageShell } from "@/components/layout/Sidebar";
import {
  Table, TableHead, Th, TableBody, Tr, Td,
  TableSkeleton, TableEmpty,
} from "@/components/ui/Table";
import { ApplicationBadge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Modal, ModalFooter } from "@/components/ui/Modal";
import { formatDate } from "@techia/utils";
import { getErrorMessage } from "@/lib/utils";
import {
  useApplications,
  useCreateApplication,
  useDeleteApplication,
  useUpdateApplicationStatus,
  useCandidates,
  useOffers,
} from "@/lib/hooks";
import type { ApplicationWithRelations, ApplicationStatus } from "@techia/types";

const STATUS_OPTIONS: Record<string, ApplicationStatus[]> = {
  applied: ["interview", "rejected"],
  interview: ["accepted", "rejected"],
};

export default function ApplicationsPage() {
  const { data: applications = [], isLoading, error, refetch } = useApplications();
  const updateStatus = useUpdateApplicationStatus();
  const createApplication = useCreateApplication();
  const deleteApplication = useDeleteApplication();

  const [statusOpen, setStatusOpen] = useState(false);
  const [statusTarget, setStatusTarget] = useState<ApplicationWithRelations | null>(null);
  const [selectedStatus, setSelectedStatus] = useState<ApplicationStatus>("interview");
  const [statusError, setStatusError] = useState<string | null>(null);

  const [addOpen, setAddOpen] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [form, setForm] = useState({ candidateId: "", offerId: "", source: "" });

  const { data: candidates = [] } = useCandidates();
  const { data: offers = [] } = useOffers();

  const activeOffers = useMemo(() => offers.filter((o) => o.isActive), [offers]);

  function openStatus(app: ApplicationWithRelations) {
    setStatusTarget(app);
    const options = STATUS_OPTIONS[app.status];
    setSelectedStatus(options?.[0] ?? "interview");
    setStatusError(null);
    setStatusOpen(true);
  }

  async function handleStatusUpdate() {
    if (!statusTarget) return;

    try {
      setStatusError(null);
      await updateStatus.mutateAsync({
        id: statusTarget.id,
        data: { status: selectedStatus },
      });
      setStatusOpen(false);
    } catch (err) {
      setStatusError(getErrorMessage(err));
    }
  }

  function openAdd() {
    setForm({ candidateId: "", offerId: "", source: "" });
    setFormError(null);
    setAddOpen(true);
  }

  async function handleAdd() {
    if (!form.candidateId || !form.offerId) {
      setFormError("Candidate and Offer are required.");
      return;
    }

    try {
      setFormError(null);
      await createApplication.mutateAsync({
        candidateId: form.candidateId,
        offerId: form.offerId,
        source: form.source.trim() || undefined,
      });
      setAddOpen(false);
    } catch (err) {
      setFormError(getErrorMessage(err));
    }
  }

  const [deleteTarget, setDeleteTarget] = useState<ApplicationWithRelations | null>(null);

  async function handleDelete() {
    if (!deleteTarget) return;
    try {
      await deleteApplication.mutateAsync(deleteTarget.id);
      setDeleteTarget(null);
    } catch { }
  }

  const statusOptions = statusTarget ? STATUS_OPTIONS[statusTarget.status] ?? [] : [];

  return (
    <PageShell
      title="Applications"
      action={
        <Button variant="primary" onClick={openAdd} icon={<PlusIcon />}>
          New application
        </Button>
      }
    >
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
            <Th>Offer</Th>
            <Th>Status</Th>
            <Th>Applied</Th>
            <Th></Th>
          </tr>
        </TableHead>

        {isLoading ? (
          <TableSkeleton cols={5} />
        ) : applications.length === 0 ? (
          <TableEmpty cols={5} message="No applications found" />
        ) : (
          <TableBody>
            {applications.map((a) => (
              <Tr key={a.id}>
                <Td>
                  <p className="font-medium text-zinc-800">{a.candidate.name}</p>
                  <p className="text-xs text-zinc-400">{a.candidate.phone}</p>
                </Td>
                <Td>
                  <p className="font-medium text-zinc-800">{a.offer.title}</p>
                  {a.offer.company && (
                    <p className="text-xs text-zinc-400">{a.offer.company}</p>
                  )}
                </Td>
                <Td>
                  <ApplicationBadge status={a.status} />
                </Td>
                <Td className="text-zinc-400">
                  {formatDate(new Date(a.createdAt))}
                </Td>
                <Td>
                  <div className="flex gap-1">
                    {STATUS_OPTIONS[a.status] && (
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => openStatus(a)}
                      >
                        Update status
                      </Button>
                    )}
                    <button
                      className="p-1.5 text-zinc-400 hover:text-red-600 transition-colors"
                      onClick={() => setDeleteTarget(a)}
                      title="Delete application"
                    >
                      <TrashIcon />
                    </button>
                  </div>
                </Td>
              </Tr>
            ))}
          </TableBody>
        )}
      </Table>

      <Modal
        open={addOpen}
        onClose={() => setAddOpen(false)}
        title="New application"
        description="Assign a candidate to an offer."
      >
        <div className="space-y-3">
          <Field label="Candidate *">
            <select
              value={form.candidateId}
              onChange={(e) => setForm({ ...form, candidateId: e.target.value })}
              className={inputCls}
            >
              <option value="">Select a candidate…</option>
              {candidates.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name} — {c.phone}
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
              <option value="">Select an offer…</option>
              {activeOffers.map((o) => (
                <option key={o.id} value={o.id}>
                  {o.title}{o.company ? ` — ${o.company}` : ""}
                </option>
              ))}
            </select>
          </Field>
          <Field label="Source">
            <input
              type="text"
              value={form.source}
              onChange={(e) => setForm({ ...form, source: e.target.value })}
              placeholder="LinkedIn, referral, etc."
              className={inputCls}
            />
          </Field>
          {formError && <p className="text-sm text-red-600">{formError}</p>}
        </div>
        <ModalFooter
          onCancel={() => setAddOpen(false)}
          onConfirm={handleAdd}
          confirmLabel="Create application"
          loading={createApplication.isPending}
        />
      </Modal>

      <Modal
        open={statusOpen}
        onClose={() => setStatusOpen(false)}
        title="Update application status"
        size="sm"
        description={
          statusTarget
            ? `${statusTarget.candidate.name} — ${statusTarget.offer.title}`
            : ""
        }
      >
        <div className="space-y-3">
          <Field label="New status">
            <select
              value={selectedStatus}
              onChange={(e) => setSelectedStatus(e.target.value as ApplicationStatus)}
              className={inputCls}
            >
              {statusOptions.map((s) => (
                <option key={s} value={s}>
                  {s.charAt(0).toUpperCase() + s.slice(1)}
                </option>
              ))}
            </select>
          </Field>
          {statusError && <p className="text-sm text-red-600">{statusError}</p>}
        </div>
        <ModalFooter
          onCancel={() => setStatusOpen(false)}
          onConfirm={handleStatusUpdate}
          confirmLabel={`Mark as ${selectedStatus}`}
          loading={updateStatus.isPending}
        />
      </Modal>
      <Modal
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        title="Delete application"
        size="sm"
        description={
          deleteTarget
            ? `Remove ${deleteTarget.candidate.name} from ${deleteTarget.offer.title}?`
            : ""
        }
      >
        <p className="text-sm text-zinc-500">This action cannot be undone.</p>
        <ModalFooter
          onCancel={() => setDeleteTarget(null)}
          onConfirm={handleDelete}
          confirmLabel="Delete"
          confirmVariant="danger"
          loading={deleteApplication.isPending}
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

function TrashIcon() {
  return (
    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
    </svg>
  );
}

function PlusIcon() {
  return (
    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
    </svg>
  );
}
