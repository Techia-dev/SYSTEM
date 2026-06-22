import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/core/responsive/responsive.dart';
import 'package:techia_ats/blocs/commissions/commissions_bloc.dart';
import 'package:techia_ats/presentation/widgets/common/common_widgets.dart';

class CommissionsScreen extends StatefulWidget {
  const CommissionsScreen({super.key});

  @override
  State<CommissionsScreen> createState() => _CommissionsScreenState();
}

class _CommissionsScreenState extends State<CommissionsScreen> with WidgetsBindingObserver {
  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommissionsBloc>().add(CommissionsLoad());
      _didInitialLoad = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _didInitialLoad) {
      context.read<CommissionsBloc>().add(CommissionsLoad());
    }
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
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (state.isLoading)
                    const Center(child: CircularProgressIndicator(color: AppColors.accentEmerald))
                  else if (state.error != null)
                    buildError(context, state.error!, () =>
                        context.read<CommissionsBloc>().add(CommissionsLoad()))
                  else if (state.items.isEmpty)
                    buildEmpty('No commissions found')
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final c = items[i];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.chartPaid.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                c.candidateName.isNotEmpty ? c.candidateName[0].toUpperCase() : '?',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.chartPaid,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(c.candidateName, style: AppTextStyles.titleSmall),
            subtitle: Row(
              children: [
                Text('${c.amount.toStringAsFixed(0)} EGP', style: AppTextStyles.bodySmall),
                const SizedBox(width: 8),
                StatusBadge(label: c.status),
              ],
            ),
            children: [
              _detailRow(Icons.work_outline, 'Offer', c.offerTitle),
              _detailRow(Icons.attach_money, 'Amount', '${c.amount.toStringAsFixed(0)} EGP'),
              _detailRow(Icons.calendar_today, 'Due date', formatDate(c.dueDate)),
              _detailRow(Icons.check_circle_outline, 'Earned', formatDate(c.earnedAt)),
              if (c.status == 'pending') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _markAsPaid(c),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Mark as paid'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentEmerald,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _markAsPaid(Commission c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as paid'),
        content: Text('Mark commission of ${c.amount.toStringAsFixed(0)} EGP for ${c.candidateName} as paid?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<CommissionsBloc>().add(CommissionsUpdateStatus(c.id, 'paid'));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentEmerald),
            child: const Text('Mark paid'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }

}
