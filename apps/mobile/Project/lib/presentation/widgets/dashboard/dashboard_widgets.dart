import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';

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
          Text(value, style: AppTextStyles.displayMedium.copyWith(fontSize: 28)),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class MonthlyOverviewChart extends StatelessWidget {
  const MonthlyOverviewChart({super.key});

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 6),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${value.toInt()}',
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        final index = value.toInt();
                        if (index < 1 || index > 12) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            months[index],
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: 6,
                minY: 0,
                maxY: 2500,
                lineBarsData: [
                  _line('Accepted', AppColors.chartAccepted, _acceptedData),
                  _line('Rejected', AppColors.chartRejected, _rejectedData),
                  _line('Paid commissions', AppColors.chartPaid, _paidData),
                  _line('Pending commissions', AppColors.chartPending, _pendingData),
                ],
                lineTouchData: const LineTouchData(enabled: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _legendDot(AppColors.chartAccepted, 'Accepted'),
              _legendDot(AppColors.chartRejected, 'Rejected'),
              _legendDot(AppColors.chartPaid, 'Paid commissions'),
              _legendDot(AppColors.chartPending, 'Pending commissions'),
            ],
          ),
        ],
      ),
    );
  }

  LineChartBarData _line(String label, Color color, List<FlSpot> data) {
    return LineChartBarData(
      spots: data,
      isCurved: true,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.08),
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

// Sample data matching the web app's chart shape
final List<FlSpot> _acceptedData = [
  const FlSpot(1, 1800),
  const FlSpot(2, 1600),
  const FlSpot(3, 2000),
  const FlSpot(4, 1700),
  const FlSpot(5, 2100),
  const FlSpot(6, 1900),
];

final List<FlSpot> _rejectedData = [
  const FlSpot(1, 400),
  const FlSpot(2, 600),
  const FlSpot(3, 300),
  const FlSpot(4, 500),
  const FlSpot(5, 700),
  const FlSpot(6, 400),
];

final List<FlSpot> _paidData = [
  const FlSpot(1, 1400),
  const FlSpot(2, 1200),
  const FlSpot(3, 1600),
  const FlSpot(4, 1300),
  const FlSpot(5, 1800),
  const FlSpot(6, 1500),
];

final List<FlSpot> _pendingData = [
  const FlSpot(1, 600),
  const FlSpot(2, 800),
  const FlSpot(3, 500),
  const FlSpot(4, 700),
  const FlSpot(5, 400),
  const FlSpot(6, 600),
];
