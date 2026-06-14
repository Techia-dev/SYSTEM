import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

class PipelineStageIndicator extends StatelessWidget {
  final String currentStage;

  const PipelineStageIndicator({
    super.key,
    required this.currentStage,
  });

  int get _activeIndex =>
      AppConstants.pipelineStages.indexOf(currentStage.toLowerCase());

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppConstants.pipelineStages.asMap().entries.map((entry) {
        final index = entry.key;
        final stage = entry.value;
        final isActive = index == _activeIndex;
        final isPast = index < _activeIndex;

        return Expanded(
          child: _StageTab(
            label: stage[0].toUpperCase() + stage.substring(1),
            isActive: isActive,
            isPast: isPast,
            isLast: index == AppConstants.pipelineStages.length - 1,
          ),
        );
      }).toList(),
    );
  }
}

class _StageTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isPast;
  final bool isLast;

  const _StageTab({
    required this.label,
    required this.isActive,
    required this.isPast,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    Color bgColor;

    if (isActive) {
      dotColor = AppColors.accentEmerald;
      bgColor = AppColors.accentEmerald.withValues(alpha: 0.08);
    } else if (isPast) {
      dotColor = AppColors.accentEmerald;
      bgColor = AppColors.bgSecondary;
    } else {
      dotColor = AppColors.textMuted;
      bgColor = AppColors.bgSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      margin: EdgeInsets.only(right: isLast ? 0 : 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textMuted,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
