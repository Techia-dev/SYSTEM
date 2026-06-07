"use client";

import { useState, useCallback, useEffect } from "react";
import { PageShell } from "@/components/layout/Sidebar";
import {
  Table, TableHead, Th, TableBody, Tr, Td,
  TableSkeleton, TableEmpty,
} from "@/components/ui/Table";
import { ApplicationBadge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Modal, ModalFooter } from "@/components/ui/Modal";
import { sdk } from "@/lib/sdk";
import { formatDate } from "@techia/utils";
import { getErrorMessage } from "@/lib/utils";
import type { ApplicationWithRelations, ApplicationStatus } from "@techia/types";

export default function ApplicationsPage() {
  const [applications, setApplications] = useState<ApplicationWithRelations[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [statusOpen, setStatusOpen] = useState(false);
  const [statusTarget, setStatusTarget] = useState<ApplicationWithRelations | null>(null);
  const [newStatus, setNewStatus] = useState<ApplicationStatus>("interview");
  const [statusSaving, setStatusSaving] = useState(false);
  const [statusError, setStatusError] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      setError(null);
      const res = await sdk.applications.list();
      setApplications(res.data);
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  function openStatus(app: ApplicationWithRelations) {
    setStatusTarget(app);

    const next: ApplicationStatus =
      app.status === "applied"
        ? "interview"
        : app.status === "interview"
          ? "accepted"
          : "rejected";

    setNewStatus(next);
    setStatusError(null);
    setStatusOpen(true);
  }

  async function handleStatusUpdate() {
    if (!statusTarget) return;

    try {
      setStatusSaving(true);
      setStatusError(null);

      await sdk.applications.updateStatus(statusTarget.id, {
        status: newStatus,
      });

      setStatusOpen(false);
      await load();
    } catch (err) {
      setStatusError(getErrorMessage(err));
    } finally {
      setStatusSaving(false);
    }
  }

  return (
    <PageShell title="Applications">
      <div className="flex gap-2 mb-4">
        <p className="text-sm text-zinc-500">
          Applications are created by candidates. Update status to progress them.
        </p>
      </div>

      {error && (
        <div className="mb-4 px-4 py-3 rounded-lg bg-red-50 border border-red-200 text-sm text-red-700 flex justify-between">
          {error}
          <button onClick={load} className="underline">Retry</button>
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

        {loading ? (
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
                  {a.status !== "accepted" && a.status !== "rejected" && (
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => openStatus(a)}
                    >
                      Move to {a.status === "applied" ? "Interview" : "Accepted"}
                    </Button>
                  )}
                </Td>
              </Tr>
            ))}
          </TableBody>
        )}
      </Table>

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
          <p className="text-sm text-zinc-500">
            Change status to <strong>{newStatus}</strong>?
          </p>

          {statusError && (
            <p className="text-sm text-red-600">{statusError}</p>
          )}
        </div>

        <ModalFooter
          onCancel={() => setStatusOpen(false)}
          onConfirm={handleStatusUpdate}
          confirmLabel={`Mark as ${newStatus}`}
          loading={statusSaving}
        />
      </Modal>
    </PageShell>
  );
}