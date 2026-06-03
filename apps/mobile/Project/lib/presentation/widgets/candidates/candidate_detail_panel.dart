import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/candidate_model.dart';
import '../../../providers/candidates_provider.dart';
import '../common/common_widgets.dart';
import 'pipeline_stage_indicator.dart';

class CandidateDetailPanel extends StatelessWidget {
  final Candidate candidate;

  const CandidateDetailPanel({
    super.key,
    required this.candidate,
  });

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
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionChip(label: 'Selected Candidate'),
                const SizedBox(height: 16),
                Text('Details', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Everything we know about the currently focused candidate.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Candidate card
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCandidateHeader(),
                const SizedBox(height: 20),
                _buildInfoGrid(),
                const SizedBox(height: 20),
                _buildActionButtons(context),
                const SizedBox(height: 24),
                _buildPipelineSection(),
                const SizedBox(height: 24),
                _buildMetadataSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateHeader() {
    return Row(
      children: [
        CandidateAvatar(name: candidate.name, size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(candidate.name, style: AppTextStyles.titleMedium),
              const SizedBox(height: 2),
              Text(candidate.displayPhone, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        StatusBadge(label: candidate.status),
      ],
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        Expanded(
          child: InfoRow(label: 'Phone', value: candidate.displayPhone),
        ),
        Expanded(
          child: InfoRow(label: 'Email', value: candidate.displayEmail),
        ),
      ],
    );
  }

  Widget _buildLevelCreatedRow() {
    return Row(
      children: [
        Expanded(
          child: InfoRow(label: 'Level', value: candidate.level),
        ),
        Expanded(
          child: InfoRow(
            label: 'Created',
            value: DateUtils.formatDateTime(candidate.createdAt),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildLevelCreatedRow(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppOutlinedButton(
                label: 'View',
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Consumer<CandidatesProvider>(
                builder: (context, provider, _) {
                  return AppPrimaryButton(
                    label: 'Advance to Interview',
                    onPressed: candidate.status == 'applied'
                        ? () => provider.advanceToInterview(candidate.id)
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            AppOutlinedButton(
              label: 'Refresh',
              onPressed: () =>
                  context.read<CandidatesProvider>().refreshSelectedCandidate(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPipelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pipeline stage', style: AppTextStyles.titleSmall),
        const SizedBox(height: 12),
        PipelineStageIndicator(currentStage: candidate.status),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InfoRow(label: 'Candidate ID', value: candidate.id),
              ),
              Expanded(
                child: InfoRow(label: 'Status', value: candidate.status),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InfoRow(label: 'Level', value: candidate.level),
              ),
              Expanded(
                child: InfoRow(
                  label: 'Created At',
                  value: DateUtils.formatDateTime(candidate.createdAt),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
