import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/core/responsive/responsive.dart';
import 'package:techia_ats/blocs/commissions/commissions_bloc.dart';

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
      context.read<CommissionsBloc>().add(CommissionsLoad());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommissionsBloc, CommissionsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: screenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Commissions', style: AppTextStyles.headlineLarge),
                            const SizedBox(height: 4),
                            Text(
                              'Commissions are created automatically when an application is accepted.',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.read<CommissionsBloc>().add(CommissionsLoad()),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (state.isLoading)
                    const Center(child: CircularProgressIndicator(color: AppColors.accentEmerald))
                  else if (state.error != null)
                    _buildError(state.error!)
                  else if (state.items.isEmpty)
                    _buildEmpty()
                  else
                    _buildTable(state.items),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTable(List<Commission> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(child: Text('Candidate', style: AppTextStyles.tableHeader)),
                Expanded(child: Text('Offer', style: AppTextStyles.tableHeader)),
                Expanded(child: Text('Amount', style: AppTextStyles.tableHeader)),
                Expanded(child: Text('Status', style: AppTextStyles.tableHeader)),
                Expanded(child: Text('Due date', style: AppTextStyles.tableHeader)),
                Expanded(child: Text('Earned', style: AppTextStyles.tableHeader)),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (_, i) {
              final c = items[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.candidateName, style: AppTextStyles.titleSmall),
                          Text(c.candidateName.isNotEmpty ? '' : '', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Expanded(child: Text(c.offerTitle, style: AppTextStyles.bodyMedium)),
                    Expanded(child: Text('\EGP ${c.amount.toStringAsFixed(0)}', style: AppTextStyles.bodyMedium)),
                    Expanded(child: _StatusBadge(c.status)),
                    Expanded(child: Text(_formatDate(c.dueDate), style: AppTextStyles.bodySmall)),
                    Expanded(child: Text(_formatDate(c.earnedAt), style: AppTextStyles.bodySmall)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _StatusBadge(String status) {
    final isPaid = status.toLowerCase() == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPaid ? AppColors.accentEmerald.withValues(alpha: 0.1) : AppColors.statusPending.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: AppTextStyles.bodySmall.copyWith(
          color: isPaid ? AppColors.accentEmerald : AppColors.statusPending,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  Widget _buildError(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accentEmerald),
            onPressed: () => context.read<CommissionsBloc>().add(CommissionsLoad()),
          ),
          const SizedBox(height: 12),
          Text(error, style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusRejected)),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(child: Text('No commissions found', style: AppTextStyles.bodyMedium)),
    );
  }
}
