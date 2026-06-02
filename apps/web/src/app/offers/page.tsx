"use client";

import { useState, useCallback, useEffect } from "react";
import { PageShell } from "@/components/layout/Sidebar";
import {
  Table, TableHead, Th, TableBody, Tr, Td,
  TableSkeleton, TableEmpty, AmountCell,
} from "@/components/ui/Table";
import { OfferStatusBadge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Modal, ModalFooter } from "@/components/ui/Modal";
import { api } from "@/lib/api";
import { formatDate } from "@techia/utils";
import { getErrorMessage } from "@/lib/utils";
import type { Offer, CreateOfferDto, UpdateOfferDto } from "@techia/types";

export default function OffersPage() {
  const [offers, setOffers]   = useState<Offer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState<string | null>(null);
  const [search, setSearch]   = useState("");
  const [showInactive, setShowInactive] = useState(false);

  // add / edit modal
  const [modalOpen, setModalOpen]   = useState(false);
  const [editTarget, setEditTarget] = useState<Offer | null>(null);
  const [saving, setSaving]         = useState(false);
  const [formError, setFormError]   = useState<string | null>(null);
  const [form, setForm] = useState<CreateOfferDto>({
    title: "", company: "", description: "",
    commission: 0, commissionDelay: 0, isActive: true,
  });

  // deactivate confirm modal
  const [deactOpen, setDeactOpen]     = useState(false);
  const [deactTarget, setDeactTarget] = useState<Offer | null>(null);
  const [deactSaving, setDeactSaving] = useState(false);

  const load = useCallback(async () => {
    try {
      setError(null);

      const data = await api.offers.list();

      setOffers(data);
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }, []);




  useEffect(() => {
    void load();
  }, [load]);

  const filtered = offers.filter((o) => {
    const matchActive = showInactive || o.isActive;
    const matchSearch =
      search === "" ||
      o.title.toLowerCase().includes(search.toLowerCase()) ||
      (o.company ?? "").toLowerCase().includes(search.toLowerCase());

    return matchActive && matchSearch;
  });
  // ── Add ────────────────────────────────────────────────────
  function openAdd() {
    setEditTarget(null);
    setForm({ title: "", company: "", description: "", commission: 0, commissionDelay: 0, isActive: true });
    setFormError(null);
    setModalOpen(true);
  }

  // ── Edit ───────────────────────────────────────────────────
  function openEdit(offer: Offer) {
    setEditTarget(offer);
    setForm({
      title:            offer.title,
      company:          offer.company ?? "",
      description:      offer.description ?? "",
      commission:       offer.commission,
      commissionDelay:  offer.commissionDelay,
      isActive:         offer.isActive,
    });
    setFormError(null);
    setModalOpen(true);
  }

  async function handleSave() {
    if (!form.title.trim()) {
      setFormError("Title is required.");
      return;
    }
    try {
      setSaving(true);
      setFormError(null);
      const payload = {
        title:           form.title.trim(),
        company:         form.company?.trim() || undefined,
        description:     form.description?.trim() || undefined,
        commission:      Number(form.commission),
        commissionDelay: Number(form.commissionDelay),
        isActive:        form.isActive,
      };
      if (editTarget) {
        await api.offers.update(editTarget.id, payload as UpdateOfferDto);
      } else {
        await api.offers.create(payload as CreateOfferDto);
      }
      setModalOpen(false);
      await load();
    } catch (err) {
      setFormError(getErrorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  // ── Deactivate ─────────────────────────────────────────────
  function openDeact(offer: Offer) {
    setDeactTarget(offer);
    setDeactOpen(true);
  }

  async function handleDeact() {
    if (!deactTarget) return;
    try {
      setDeactSaving(true);
      await api.offers.deactivate(deactTarget.id);
      setDeactOpen(false);
      await load();
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setDeactSaving(false);
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
      <div className="flex gap-2 mb-4">
        <input
          type="text"
          placeholder="Search title or company…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="h-8 px-3 text-sm rounded-lg border border-zinc-200 bg-white text-zinc-800 placeholder:text-zinc-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 w-64"
        />
        <label className="flex items-center gap-2 text-sm text-zinc-500 cursor-pointer select-none">
          <input
            type="checkbox"
            checked={showInactive}
            onChange={(e) => setShowInactive(e.target.checked)}
            className="rounded border-zinc-300 text-emerald-600 focus:ring-emerald-500"
          />
          Show inactive
        </label>
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
            <Th>Title</Th>
            <Th>Company</Th>
            <Th>Commission</Th>
            <Th>Delay (days)</Th>
            <Th>Status</Th>
            <Th>Created</Th>
            <Th></Th>
          </tr>
        </TableHead>
        {loading ? (
          <TableSkeleton cols={7} />
        ) : filtered.length === 0 ? (
          <TableEmpty cols={7} message="No offers found" />
        ) : (
          <TableBody>
            {filtered.map((o) => (
              <Tr key={o.id}>
                <Td>
                  <p className="font-medium text-zinc-800">{o.title}</p>
                </Td>
                <Td className="text-zinc-500">{o.company ?? "—"}</Td>
                <Td><AmountCell amount={o.commission} /></Td>
                <Td className="text-zinc-500">{o.commissionDelay}</Td>
                <Td><OfferStatusBadge isActive={o.isActive} /></Td>
                <Td className="text-zinc-400">{formatDate(new Date(o.createdAt))}</Td>
                <Td>
                  <div className="flex gap-1.5">
                    <Button variant="ghost" size="sm" onClick={() => openEdit(o)}>
                      Edit
                    </Button>
                    {o.isActive && (
                      <Button variant="ghost" size="sm" onClick={() => openDeact(o)}
                        className="text-red-500 hover:text-red-700 hover:bg-red-50">
                        Deactivate
                      </Button>
                    )}
                  </div>
                </Td>
              </Tr>
            ))}
          </TableBody>
        )}
      </Table>

      {/* Add / Edit Modal */}
      <Modal open={modalOpen} onClose={() => setModalOpen(false)}
        title={editTarget ? "Edit offer" : "New offer"}
        description={editTarget ? `Editing: ${editTarget.title}` : "Fill in the offer details."}
        size="lg">
        <div className="space-y-3">
          <Field label="Title *">
            <input type="text" placeholder="React Developer" value={form.title}
              onChange={(e) => setForm({ ...form, title: e.target.value })}
              className={inputCls} />
          </Field>
          <div className="grid grid-cols-2 gap-3">
            <Field label="Company">
              <input type="text" placeholder="Techia Corp" value={form.company}
                onChange={(e) => setForm({ ...form, company: e.target.value })}
                className={inputCls} />
            </Field>
            <Field label="Commission (EGP)">
              <input type="number" min={0} placeholder="5000" value={form.commission}
                onChange={(e) => setForm({ ...form, commission: Number(e.target.value) })}
                className={inputCls} />
            </Field>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <Field label="Commission delay (days)">
              <input type="number" min={0} placeholder="30" value={form.commissionDelay}
                onChange={(e) => setForm({ ...form, commissionDelay: Number(e.target.value) })}
                className={inputCls} />
            </Field>
            <Field label="Status">
              <select value={form.isActive ? "active" : "inactive"}
                onChange={(e) => setForm({ ...form, isActive: e.target.value === "active" })}
                className={inputCls}>
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </Field>
          </div>
          <Field label="Description">
            <textarea placeholder="Job description…" value={form.description}
              onChange={(e) => setForm({ ...form, description: e.target.value })}
              rows={3}
              className="w-full px-3 py-2 text-sm rounded-lg border border-zinc-200 bg-white text-zinc-800 focus:outline-none focus:ring-2 focus:ring-emerald-500 resize-none" />
          </Field>
          {formError && <p className="text-sm text-red-600">{formError}</p>}
        </div>
        <ModalFooter onCancel={() => setModalOpen(false)} onConfirm={handleSave}
          confirmLabel={editTarget ? "Save changes" : "Create offer"} loading={saving} />
      </Modal>

      {/* Deactivate Confirm */}
      <Modal open={deactOpen} onClose={() => setDeactOpen(false)}
        title="Deactivate offer" size="sm"
        description={deactTarget ? `Are you sure you want to deactivate "${deactTarget.title}"?` : ""}>
        <p className="text-sm text-zinc-500">
          The offer will be hidden from new applications. Existing applications will not be affected.
        </p>
        <ModalFooter onCancel={() => setDeactOpen(false)} onConfirm={handleDeact}
          confirmLabel="Deactivate" confirmVariant="danger" loading={deactSaving} />
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