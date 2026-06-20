import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/blocs/candidates/candidates_bloc.dart';
import '../common/common_widgets.dart';
import 'pipeline_stage_indicator.dart';

class CandidateDetailPanel extends StatelessWidget {
  final Candidate candidate;
  const CandidateDetailPanel({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SectionChip(label: 'SELECTED CANDIDATE'),
              const Spacer(),
              GestureDetector(
                onTap: () => context.read<CandidatesBloc>().add(CandidatesRefreshSelected()),
                child: const Icon(Icons.refresh, size: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CandidateAvatar(name: candidate.name, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(candidate.name, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(candidate.level, style: AppTextStyles.bodySmall),
                        const SizedBox(width: 8),
                        StatusBadge(label: candidate.status),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const LabeledDivider(label: 'CONTACT'),
          const SizedBox(height: 12),
          InfoRow(label: 'Phone', value: candidate.displayPhone),
          const SizedBox(height: 12),
          InfoRow(label: 'Email', value: candidate.displayEmail),
          const SizedBox(height: 20),
          const LabeledDivider(label: 'PIPELINE'),
          const SizedBox(height: 12),
          PipelineStageIndicator(currentStage: candidate.status),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppPrimaryButton(
                  label: 'Advance to Interview',
                  icon: Icons.arrow_forward,
                  onPressed: () => context.read<CandidatesBloc>().add(
                    CandidatesAdvanceStage(candidate.id),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
