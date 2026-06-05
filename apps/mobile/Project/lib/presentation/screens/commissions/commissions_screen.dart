import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/commission_model.dart';
import '../../../providers/commissions_provider.dart';
import '../../widgets/common/common_widgets.dart';

class CommissionsScreen extends StatefulWidget {
  const CommissionsScreen({super.key});

  @override
  State<CommissionsScreen> createState() => _CommissionsScreenState();
}

class _CommissionsScreenState extends State<CommissionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommissionsProvider>().loadCommissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Consumer<CommissionsProvider>(
            builder: (context, provider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(provider),
                  const SizedBox(height: 32),
                  _buildContent(provider),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CommissionsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: const Text('COMMISSIONS OVERVIEW', style: AppTextStyles.labelMedium),
        ),
        const SizedBox(height: 12),
        Text('Commissions', style: AppTextStyles.displayLarge),
        const SizedBox(height: 6),
        Text(
          'Track earned commissions, payment status, and due dates.',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildContent(CommissionsProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: CircularProgressIndicator(color: AppColors.accentCyan),
        ),
      );
    }

    if (provider.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(60),
          child: Text(
            provider.errorMessage ?? 'An error occurred',
            style: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFFEF4444)),
          ),
        ),
      );
    }

    if (provider.commissions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: Text('No commissions found', style: AppTextStyles.bodyMedium),
        ),
      );
    }

    final totalAmount = provider.commissions.fold<double>(
      0, (sum, c) => sum + c.amount);
    final paidCount = provider.commissions.where((c) => c.isPaid).length;
    final overdueCount = provider.commissions.where((c) => c.isOverdue).length;

    return Column(
      children: [
        _buildStatsRow(totalAmount, paidCount, overdueCount, provider.commissions.length),
        const SizedBox(height: 24),
        _buildList(provider),
      ],
    );
  }

  Widget _buildStatsRow(double totalAmount, int paidCount, int overdueCount, int total) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Total Amount',
            value: '\$${totalAmount.toStringAsFixed(2)}',
            description: 'Across all commissions',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'Paid',
            value: paidCount.toString(),
            description: '$paidCount of $total paid',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'Overdue',
            value: overdueCount.toString(),
            description: 'Past due date',
          ),
        ),
      ],
    );
  }

  Widget _buildList(CommissionsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildListHeader(provider),
          const Divider(height: 1),
          _buildListHeaderRow(),
          const Divider(height: 1),
          ...provider.commissions.map((c) => _CommissionRow(commission: c)),
        ],
      ),
    );
  }

  Widget _buildListHeader(CommissionsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const SectionChip(label: 'All Commissions'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '${provider.commissions.length} commission${provider.commissions.length == 1 ? '' : 's'}',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeaderRow() {
    const headers = ['CANDIDATE', 'OFFER', 'AMOUNT', 'STATUS', 'EARNED', 'DUE'];
    const flexes = [2, 2, 2, 1, 2, 2];

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
}

class _CommissionRow extends StatelessWidget {
  final Commission commission;
  const _CommissionRow({required this.commission});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              commission.candidateName.isEmpty
                  ? commission.candidateId
                  : commission.candidateName,
              style: AppTextStyles.titleSmall,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              commission.offerTitle.isEmpty
                  ? commission.offerId
                  : commission.offerTitle,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${commission.amount.toStringAsFixed(2)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accentCyan,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildStatusBadge(commission),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateUtils.formatDate(commission.earnedAt),
              style: AppTextStyles.bodySmall,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateUtils.formatDate(commission.dueDate),
              style: AppTextStyles.bodySmall.copyWith(
                color: commission.isOverdue
                    ? const Color(0xFFEF4444)
                    : AppColors.textMuted,
                fontWeight: commission.isOverdue
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Commission commission) {
    Color bgColor;
    Color textColor;
    String label;

    if (commission.isPaid) {
      bgColor = const Color(0xFF064E3B);
      textColor = const Color(0xFF34D399);
      label = 'Paid';
    } else if (commission.isOverdue) {
      bgColor = const Color(0xFF3B0A0A);
      textColor = const Color(0xFFEF4444);
      label = 'Overdue';
    } else {
      bgColor = const Color(0xFF1F2937);
      textColor = AppColors.textSecondary;
      label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
