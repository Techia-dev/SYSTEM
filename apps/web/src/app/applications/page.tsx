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
import { sdk } from "@/lib/sdk";
import { formatDate } from "@techia/utils";
import { getErrorMessage } from "@/lib/utils";

import type {
  ApplicationWithRelations,
  CreateApplicationDto,
  ApplicationStatus,
  Candidate,
  Offer,
  PaginatedResponse,
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

  const [statusFilter, setStatusFilter] =
    useState<ApplicationStatus | "all">("all");

  const [search, setSearch] = useState("");

  const [addOpen, setAddOpen] = useState(false);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  const [form, setForm] = useState<CreateApplicationDto>({
    candidateId: "",
    offerId: "",
    source: "",
    assignedTo: "",
  });

  const load = useCallback(async () => {
    try {
      setError(null);
      setLoading(true);

      const [apps, cands, offs] = await Promise.all([
        sdk.applications.list(),
        sdk.candidates.list(),
        sdk.offers.list(),
      ]);

      // ✅ unwrap PaginatedResponse correctly
      setApplications(apps.data);
      setCandidates(cands.data);
      setOffers(offs.data.filter((o: Offer) => o.isActive));
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const filtered = useMemo(() => {
    const term = search.trim().toLowerCase();

    return applications.filter((a) => {
      const matchStatus =
        statusFilter === "all" || a.status === statusFilter;

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

      await sdk.applications.create({
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

  return (
    <PageShell
      title="Applications"
      action={
        <Button variant="primary" onClick={openAdd} icon={<PlusIcon />}>
          New application
        </Button>
      }
    >
      {/* Filters */}
      <div className="flex gap-2 mb-4">
        <input
          type="text"
          placeholder="Search candidate or offer…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="h-8 px-3 text-sm rounded-lg border border-zinc-200"
        />

        <select
          value={statusFilter}
          onChange={(e) =>
            setStatusFilter(e.target.value as ApplicationStatus | "all")
          }
          className="h-8 px-2 text-sm rounded-lg border border-zinc-200"
        >
          {STATUSES.map((s) => (
            <option key={s.value} value={s.value}>
              {s.label}
            </option>
          ))}
        </select>
      </div>

      {/* Error */}
      {error && (
        <div className="mb-4 text-red-600">
          {error}
          <button onClick={load} className="ml-2 underline">
            Retry
          </button>
        </div>
      )}

      {/* Table */}
      <Table>
        <TableHead>
          <tr>
            <Th>Candidate</Th>
            <Th>Offer</Th>
            <Th>Status</Th>
            <Th>Source</Th>
            <Th>Assigned</Th>
            <Th>Date</Th>
          </tr>
        </TableHead>

        {loading ? (
          <TableSkeleton cols={6} />
        ) : filtered.length === 0 ? (
          <TableEmpty cols={6} message="No applications found" />
        ) : (
          <TableBody>
            {filtered.map((a) => (
              <Tr key={a.id}>
                <Td>
                  <AvatarCell
                    name={a.candidate.name}
                    sub={a.candidate.level}
                  />
                </Td>
                <Td>{a.offer.title}</Td>
                <Td>
                  <ApplicationBadge status={a.status} />
                </Td>
                <Td>{a.source ?? "—"}</Td>
                <Td>{a.assignedTo ?? "—"}</Td>
                <Td>{formatDate(new Date(a.createdAt))}</Td>
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
      >
        <div className="space-y-3">
          <Field label="Candidate">
            <select
              value={form.candidateId}
              onChange={(e) =>
                setForm({ ...form, candidateId: e.target.value })
              }
            >
              <option value="">Select</option>
              {candidates.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}
                </option>
              ))}
            </select>
          </Field>

          <Field label="Offer">
            <select
              value={form.offerId}
              onChange={(e) =>
                setForm({ ...form, offerId: e.target.value })
              }
            >
              <option value="">Select</option>
              {offers.map((o: Offer) => (
                <option key={o.id} value={o.id}>
                  {o.title}
                </option>
              ))}
            </select>
          </Field>

          {formError && (
            <p className="text-red-600 text-sm">{formError}</p>
          )}
        </div>

        <ModalFooter
          onCancel={() => setAddOpen(false)}
          onConfirm={handleAdd}
          confirmLabel="Create"
          loading={saving}
        />
      </Modal>
    </PageShell>
  );
}

function Field({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex flex-col gap-1">
      <label className="text-xs">{label}</label>
      {children}
    </div>
  );
}

function PlusIcon() {
  return (
    <svg
      className="w-4 h-4"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={2}
    >
      <path d="M12 5v14M5 12h14" />
    </svg>
  );
}