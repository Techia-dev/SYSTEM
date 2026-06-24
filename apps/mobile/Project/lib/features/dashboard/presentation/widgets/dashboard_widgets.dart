import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../candidates/bloc/candidates_bloc.dart';
import '../../../commissions/bloc/commissions_bloc.dart';

class DashboardStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  const DashboardStatCard({super.key, required this.label, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class CandidatesStatusChart extends StatelessWidget {
  const CandidatesStatusChart({super.key});

  @override
  Widget build(BuildContext context) {
    final hired = context.select<CandidatesBloc, int>((b) => b.state.hiredCount);
    final rejected = context.select<CandidatesBloc, int>((b) => b.state.rejectedCount);
    final paid = context.select<CommissionsBloc, double>((b) => b.state.items.where((c) => c.isPaid).length.toDouble());
    final pending = context.select<CommissionsBloc, double>((b) => b.state.items.where((c) => !c.isPaid).length.toDouble());

    final sections = [
      if (hired > 0) PieChartSectionData(value: hired.toDouble(), color: const Color(0xFF047857), title: '$hired', radius: 28),
      if (rejected > 0) PieChartSectionData(value: rejected.toDouble(), color: const Color(0xFFB91C1C), title: '$rejected', radius: 28),
      if (paid > 0) PieChartSectionData(value: paid.toDouble(), color: const Color(0xFF3B82F6), title: '${paid.toInt()}', radius: 28),
      if (pending > 0) PieChartSectionData(value: pending.toDouble(), color: const Color(0xFFF59E0B), title: '${pending.toInt()}', radius: 28),
    ];

    if (sections.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Candidate & Commission Status', style: AppTextStyles.titleSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 160, height: 160,
                child: PieChart(PieChartData(
                  sections: sections,
                  centerSpaceRadius: 32,
                  sectionsSpace: 2,
                )),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendDot('Hired', const Color(0xFF047857)),
                    const SizedBox(height: 8),
                    _legendDot('Rejected', const Color(0xFFB91C1C)),
                    const SizedBox(height: 8),
                    _legendDot('Paid', const Color(0xFF3B82F6)),
                    const SizedBox(height: 8),
                    _legendDot('Pending', const Color(0xFFF59E0B)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _legendDot(String label, Color color) {
  return Row(
    children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 13)),
    ],
  );
}
