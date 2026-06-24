import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../bloc/commissions_bloc.dart';

class CommissionsScreen extends StatefulWidget {
  const CommissionsScreen({super.key});

  @override
  State<CommissionsScreen> createState() => _CommissionsScreenState();
}

class _CommissionsScreenState extends State<CommissionsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommissionsBloc>().add(CommissionsLoad());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
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
                            Text('Commissions',
                                style: AppTextStyles.displayMedium),
                            const SizedBox(height: 6),
                            const SectionChip(label: 'Finance'),
                            const SizedBox(height: 4),
                            Text(state.matchingText,
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => context
                            .read<CommissionsBloc>()
                            .add(CommissionsLoad()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (state.isLoading)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator()))
                  else if (state.items.isEmpty)
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: buildEmpty(context, 'No commissions yet')))
                  else
                    ...state.items.map((c) => _buildCommissionCard(context, c)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommissionCard(BuildContext context, Commission commission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${commission.candidateName}',
                    style: AppTextStyles.titleSmall),
                Row(
                  children: [
                    Text('${commission.amount.toStringAsFixed(0)} EGP',
                        style: AppTextStyles.titleSmall),
                    const SizedBox(width: 8),
                    StatusBadge(status: commission.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Due: ${formatDate(commission.dueDate)}',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          if (commission.status == 'pending')
            TextButton(
              onPressed: () => _showMarkPaidDialog(context, commission.id),
              child: const Text('Mark as paid',
                  style:
                      TextStyle(color: AppColors.accentEmerald, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  void _showMarkPaidDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark Commission as Paid'),
        content: const Text('Confirm this commission has been paid?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context
                  .read<CommissionsBloc>()
                  .add(CommissionsUpdateStatus(id, 'paid'));
              Navigator.pop(ctx);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
