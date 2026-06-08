"use client";

import { useState, useMemo } from "react";
import { PageShell } from "@/components/layout/Sidebar";
import {
  Table, TableHead, Th, TableBody, Tr, Td,
  TableSkeleton, TableEmpty,
} from "@/components/ui/Table";
import { OfferStatusBadge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Modal, ModalFooter } from "@/components/ui/Modal";
import { getErrorMessage } from "@/lib/utils";
import { useOffers, useCreateOffer, useDeactivateOffer } from "@/lib/hooks";
import { filterOffers } from "./filters";
import type { CreateOfferDto } from "@techia/types";

export default function OffersPage() {
  const { data: offers = [], isLoading, error, refetch } = useOffers();
  const createOffer = useCreateOffer();
  const deactivateOffer = useDeactivateOffer();

  const [search, setSearch] = useState("");
  const [showInactive, setShowInactive] = useState(false);

  const [addOpen, setAddOpen] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [form, setForm] = useState<CreateOfferDto>({
    title: "",
    company: "",
    description: "",
    commission: 0,
    commissionDelay: 0,
  });

  const filtered = useMemo(
    () => filterOffers(offers, search, showInactive),
    [offers, search, showInactive],
  );

  function openAdd() {
    setForm({ title: "", company: "", description: "", commission: 0, commissionDelay: 0 });
    setFormError(null);
    setAddOpen(true);
  }

  async function handleAdd() {
    if (!form.title.trim()) {
      setFormError("Offer title is required.");
      return;
    }

    try {
      setFormError(null);
      await createOffer.mutateAsync({
        title: form.title.trim(),
        company: form.company?.trim() || undefined,
        description: form.description?.trim() || undefined,
        commission: form.commission || undefined,
        commissionDelay: form.commissionDelay || undefined,
      });
      setAddOpen(false);
    } catch (err) {
      setFormError(getErrorMessage(err));
    }
  }

  return (
    <PageShell
      title="Offers"
      action={
        <Button variant="primary" onClick={openAdd} icon={<PlusIcon />}>
          New offer
        </Button>
      }
    >
      <div className="flex gap-2 mb-4 items-center">
        <input
          type="text"
          placeholder="Search title, company…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="h-8 px-3 text-sm rounded-lg border border-zinc-200 bg-white text-zinc-800 placeholder:text-zinc-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 w-64"
        />
        <label className="flex items-center gap-1.5 text-sm text-zinc-600">
          <input
            type="checkbox"
            checked={showInactive}
            onChange={(e) => setShowInactive(e.target.checked)}
            className="rounded border-zinc-300"
          />
          Show inactive
        </label>
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
            <Th>Title</Th>
            <Th>Company</Th>
            <Th>Commission</Th>
            <Th>Status</Th>
            <Th>Created</Th>
            <Th></Th>
          </tr>
        </TableHead>

        {isLoading ? (
          <TableSkeleton cols={6} />
        ) : filtered.length === 0 ? (
          <TableEmpty cols={6} message="No offers found" />
        ) : (
          <TableBody>
            {filtered.map((o) => (
              <Tr key={o.id}>
                <Td><p className="font-medium text-zinc-800">{o.title}</p></Td>
                <Td className="text-zinc-500">{o.company ?? "—"}</Td>
                <Td>
                  <span className="font-mono text-zinc-700">
                    {new Intl.NumberFormat("en-EG", { style: "currency", currency: "EGP", minimumFractionDigits: 0 }).format(o.commission)}
                  </span>
                </Td>
                <Td><OfferStatusBadge isActive={o.isActive} /></Td>
                <Td className="text-zinc-400">
                  {new Intl.DateTimeFormat("en-US", { dateStyle: "medium" }).format(new Date(o.createdAt))}
                </Td>
                <Td>
                  {o.isActive && (
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => deactivateOffer.mutate(o.id)}
                    >
                      Deactivate
                    </Button>
                  )}
                </Td>
              </Tr>
            ))}
          </TableBody>
        )}
      </Table>

      <Modal
        open={addOpen}
        onClose={() => setAddOpen(false)}
        title="New offer"
        description="Fill in the offer details."
      >
        <div className="space-y-3">
          <Field label="Title *">
            <input value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} className={inputCls} />
          </Field>
          <Field label="Company">
            <input value={form.company ?? ""} onChange={(e) => setForm({ ...form, company: e.target.value })} className={inputCls} />
          </Field>
          <Field label="Description">
            <textarea value={form.description ?? ""} onChange={(e) => setForm({ ...form, description: e.target.value })} className={`${inputCls} resize-none h-20`} />
          </Field>
          <Field label="Commission (EGP)">
            <input type="number" min={0} value={form.commission ?? 0} onChange={(e) => setForm({ ...form, commission: Number(e.target.value) })} className={inputCls} />
          </Field>
          <Field label="Commission delay (days)">
            <input type="number" min={0} value={form.commissionDelay ?? 0} onChange={(e) => setForm({ ...form, commissionDelay: Number(e.target.value) })} className={inputCls} />
          </Field>
          {formError && <p className="text-sm text-red-600">{formError}</p>}
        </div>
        <ModalFooter
          onCancel={() => setAddOpen(false)}
          onConfirm={handleAdd}
          confirmLabel="Add offer"
          loading={createOffer.isPending}
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
    <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none">
      <path d="M12 4v16M4 12h16" stroke="currentColor" strokeWidth={2} />
    </svg>
  );
}
