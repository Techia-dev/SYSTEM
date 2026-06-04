import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/candidate_model.dart';
import '../../../providers/candidates_provider.dart';
import '../common/common_widgets.dart';

class CandidatesTable extends StatelessWidget {
  const CandidatesTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          _buildTable(context),
          const Divider(height: 1),
          _buildPagination(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<CandidatesProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const SectionChip(label: 'Candidates Table'),
              const Spacer(),
              _PageCountBadge(
                current: provider.currentPage,
                total: provider.totalPages,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '${provider.total} total',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeaderRow() {
    const headers = ['CANDIDATE', 'STATUS', 'PHONE / EMAIL', 'LEVEL', 'CREATED', 'ACTIONS'];
    final flexes = [2, 1, 2, 1, 2, 2];

    return Container(
      color: AppColors.bgSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: headers.asMap().entries.map((entry) {
          return Expanded(
            flex: flexes[entry.key],
            child: Text(
              entry.value,
              style: AppTextStyles.labelLarge.copyWith(fontSize: 11),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return Consumer<CandidatesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accentCyan),
            ),
          );
        }

        if (provider.hasError) {
          return Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Text(
                provider.errorMessage ?? 'An error occurred',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFFEF4444),
                ),
              ),
            ),
          );
        }

        if (provider.candidates.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text('No candidates found', style: AppTextStyles.bodyMedium),
            ),
          );
        }

        return Column(
          children: [
            _buildTableHeaderRow(),
            ...provider.candidates.map(
              (candidate) => _CandidateRow(
                candidate: candidate,
                isSelected: provider.selectedCandidate?.id == candidate.id,
                onTap: () => provider.selectCandidate(candidate),
                onAdvance: () => provider.advanceToInterview(candidate.id),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPagination(BuildContext context) {
    return Consumer<CandidatesProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              AppOutlinedButton(
                label: 'Previous',
                onPressed: provider.currentPage > 1
                    ? () => provider.previousPage()
                    : null,
              ),
              const Spacer(),
              Text(provider.pageText, style: AppTextStyles.bodySmall),
              const Spacer(),
              AppOutlinedButton(
                label: 'Next',
                onPressed: provider.currentPage < provider.totalPages
                    ? () => provider.nextPage()
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CandidateRow extends StatelessWidget {
  final Candidate candidate;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onAdvance;

  const _CandidateRow({
    required this.candidate,
    required this.isSelected,
    required this.onTap,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bgSurface : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          children: [
            // Candidate name
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(candidate.name, style: AppTextStyles.titleSmall),
                  Text(candidate.id, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            // Status
            Expanded(
              flex: 1,
              child: StatusBadge(label: candidate.status),
            ),
            // Phone / Email
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(candidate.displayPhone, style: AppTextStyles.bodySmall),
                  Text(
                    candidate.hasEmail ? candidate.email! : 'No email',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            // Level
            Expanded(
              flex: 1,
              child: Text(candidate.level, style: AppTextStyles.bodySmall),
            ),
            // Created
            Expanded(
              flex: 2,
              child: Text(
                DateUtils.formatDateTime(candidate.createdAt),
                style: AppTextStyles.bodySmall,
              ),
            ),
            // Actions
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  AppOutlinedButton(
                    label: 'View',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 6),
                  AppPrimaryButton(
                    label: 'Move to Interview',
                    onPressed: candidate.status == 'applied' ? onAdvance : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageCountBadge extends StatelessWidget {
  final int current;
  final int total;

  const _PageCountBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentCyan.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$current/$total',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.accentCyan,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
