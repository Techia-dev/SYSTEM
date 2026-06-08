import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { sdk } from "./sdk";
import type {
  Candidate,
  CreateCandidateDto,
  UpdateCandidateDto,
  Offer,
  CreateOfferDto,
  ApplicationWithRelations,
  CreateApplicationDto,
  UpdateApplicationStatusDto,
  CommissionWithRelations,
  UpdateCommissionStatusDto,
  DashboardStats,
} from "@techia/types";

const keys = {
  candidates: { all: ["candidates"] as const, page: (p: number) => ["candidates", "page", p] as const },
  offers: { all: ["offers"] as const },
  applications: { all: ["applications"] as const },
  commissions: { all: ["commissions"] as const },
  dashboard: { stats: ["dashboard", "stats"] as const },
};

export function useCandidates() {
  return useQuery({
    queryKey: keys.candidates.all,
    queryFn: async () => {
      const res = await sdk.candidates.list();
      return res.data;
    },
  });
}

export function useCandidatePage(page: number, pageSize = 20) {
  return useQuery({
    queryKey: keys.candidates.page(page),
    queryFn: async () => {
      const res = await sdk.candidates.list({ page, page_size: pageSize });
      return { data: res.data, total: res.total, page: res.page, totalPages: res.totalPages };
    },
    placeholderData: (prev) => prev,
  });
}

export function useCreateCandidate() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateCandidateDto) => sdk.candidates.create(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: keys.candidates.all }),
  });
}

export function useUpdateCandidate() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateCandidateDto }) =>
      sdk.candidates.update(id, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: keys.candidates.all }),
  });
}

export function useDeleteCandidate() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => sdk.candidates.delete(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: keys.candidates.all }),
  });
}

export function useUploadCv() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, file }: { id: string; file: File }) =>
      sdk.candidates.uploadCv(id, file),
    onSuccess: () => qc.invalidateQueries({ queryKey: keys.candidates.all }),
  });
}

export function useOffers() {
  return useQuery({
    queryKey: keys.offers.all,
    queryFn: async () => {
      const res = await sdk.offers.list();
      return res.data;
    },
  });
}

export function useCreateOffer() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateOfferDto) => sdk.offers.create(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: keys.offers.all }),
  });
}

export function useDeactivateOffer() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => sdk.offers.deactivate(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: keys.offers.all }),
  });
}

export function useApplications() {
  return useQuery({
    queryKey: keys.applications.all,
    queryFn: async () => {
      const res = await sdk.applications.list();
      return res.data;
    },
  });
}

export function useCreateApplication() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateApplicationDto) => sdk.applications.create(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: keys.applications.all }),
  });
}

export function useDeleteApplication() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => sdk.applications.delete(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: keys.applications.all }),
  });
}

export function useUpdateApplicationStatus() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateApplicationStatusDto }) =>
      sdk.applications.updateStatus(id, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: keys.applications.all }),
  });
}

export function useCommissions() {
  return useQuery({
    queryKey: keys.commissions.all,
    queryFn: async () => {
      const res = await sdk.commissions.list();
      return res.data;
    },
  });
}

export function useDashboardStats() {
  return useQuery({
    queryKey: keys.dashboard.stats,
    queryFn: () => sdk.dashboard.getStats(),
  });
}

export function useDashboardAnalytics() {
  return useQuery({
    queryKey: ["dashboard", "analytics"],
    queryFn: () => sdk.dashboard.getAnalytics(),
  });
}

export function useUpdateCommissionStatus() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateCommissionStatusDto }) =>
      sdk.commissions.updateStatus(id, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: keys.commissions.all }),
  });
}
