import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/blocs/candidates/candidates_bloc.dart';
import 'package:techia_ats/blocs/commissions/commissions_bloc.dart';

class DashboardStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;

  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Text(value,
              style: AppTextStyles.displayMedium.copyWith(fontSize: 20)),
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
    final accepted =
        context.select<CandidatesBloc, int>((b) => b.state.hiredCount);
    final rejected =
        context.select<CandidatesBloc, int>((b) => b.state.rejectedCount);
    final paidCommissions = context.select<CommissionsBloc, double>((b) => b
        .state.items
        .where((c) => c.isPaid)
        .fold<double>(0, (sum, c) => sum + c.amount));
    final pendingCommissions = context.select<CommissionsBloc, double>((b) => b
        .state.items
        .where((c) => !c.isPaid)
        .fold<double>(0, (sum, c) => sum + c.amount));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MONTHLY OVERVIEW', style: AppTextStyles.labelLarge),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: accepted.toDouble(),
                    color: AppColors.chartAccepted,
                    title: '${accepted}',
                    radius: 45,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: rejected.toDouble(),
                    color: AppColors.chartRejected,
                    title: '${rejected}',
                    radius: 45,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: paidCommissions,
                    color: AppColors.chartPaid,
                    title: '${paidCommissions.toStringAsFixed(0)}',
                    radius: 45,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: pendingCommissions,
                    color: AppColors.chartPending,
                    title: '${pendingCommissions.toStringAsFixed(0)}',
                    radius: 45,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _legendDot(AppColors.chartAccepted, 'Accepted ($accepted)'),
              _legendDot(AppColors.chartRejected, 'Rejected ($rejected)'),
              _legendDot(AppColors.chartPaid,
                  'Paid ${paidCommissions.toStringAsFixed(0)} EGP'),
              _legendDot(AppColors.chartPending,
                  'Pending ${pendingCommissions.toStringAsFixed(0)} EGP'),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _legendDot(Color color, String label) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
    ],
  );
}
