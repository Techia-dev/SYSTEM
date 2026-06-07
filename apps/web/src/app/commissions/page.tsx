"use client";

import { useCallback, useEffect, useState } from "react";
import { PageShell } from "@/components/layout/Sidebar";
import {
  Table, TableHead, Th, TableBody, Tr, Td,
  TableSkeleton, TableEmpty, AmountCell,
} from "@/components/ui/Table";
import { CommissionBadge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Modal, ModalFooter } from "@/components/ui/Modal";
import { sdk } from "@/lib/sdk";
import { formatDate } from "@techia/utils";
import { getErrorMessage } from "@/lib/utils";
import type { CommissionWithRelations, CommissionStatus } from "@techia/types";

export default function CommissionsPage() {
  const [commissions, setCommissions] = useState<CommissionWithRelations[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [statusOpen, setStatusOpen] = useState(false);
  const [statusTarget, setStatusTarget] = useState<CommissionWithRelations | null>(null);
  const [newStatus, setNewStatus] = useState<CommissionStatus>("pending");
  const [statusSaving, setStatusSaving] = useState(false);
  const [statusError, setStatusError] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      const res = await sdk.commissions.list();

      // SDK standard
      setCommissions(res.data);

    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  function openStatus(commission: CommissionWithRelations) {
    setStatusTarget(commission);
    setNewStatus("paid");
    setStatusError(null);
    setStatusOpen(true);
  }

  async function handleStatusUpdate() {
    if (!statusTarget) return;

    try {
      setStatusSaving(true);
      setStatusError(null);

      await sdk.commissions.updateStatus(statusTarget.id, {
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
    <PageShell title="Commissions">
      <div className="flex gap-2 mb-4">
        <p className="text-sm text-zinc-500">
          Commissions are created automatically when an application is accepted.
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
            <Th>Amount</Th>
            <Th>Status</Th>
            <Th>Due date</Th>
            <Th>Earned</Th>
            <Th></Th>
          </tr>
        </TableHead>

        {loading ? (
          <TableSkeleton cols={7} />
        ) : commissions.length === 0 ? (
          <TableEmpty cols={7} message="No commissions found" />
        ) : (
          <TableBody>
            {commissions.map((c) => (
              <Tr key={c.id}>
                <Td>
                  <p className="font-medium text-zinc-800">{c.candidate.name}</p>
                  <p className="text-xs text-zinc-400">{c.candidate.phone}</p>
                </Td>

                <Td>
                  <p className="font-medium text-zinc-800">{c.offer.title}</p>
                  {c.offer.company && (
                    <p className="text-xs text-zinc-400">{c.offer.company}</p>
                  )}
                </Td>

                <Td>
                  <AmountCell amount={c.amount} />
                </Td>

                <Td>
                  <CommissionBadge status={c.status} />
                </Td>

                <Td className="text-zinc-400">
                  {formatDate(new Date(c.dueDate))}
                </Td>

                <Td className="text-zinc-400">
                  {c.earnedAt ? formatDate(new Date(c.earnedAt)) : "—"}
                </Td>

                <Td>
                  {c.status === "pending" && (
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => openStatus(c)}
                    >
                      Mark paid
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
        title="Update commission status"
        size="sm"
        description={
          statusTarget
            ? `${statusTarget.candidate.name} — ${statusTarget.offer.title}`
            : ""
        }
      >
        <div className="space-y-3">
          <p className="text-sm text-zinc-500">
            Mark this commission as paid?
          </p>

          {statusError && (
            <p className="text-sm text-red-600">{statusError}</p>
          )}
        </div>

        <ModalFooter
          onCancel={() => setStatusOpen(false)}
          onConfirm={handleStatusUpdate}
          confirmLabel="Mark as paid"
          loading={statusSaving}
        />
      </Modal>
    </PageShell>
  );
}