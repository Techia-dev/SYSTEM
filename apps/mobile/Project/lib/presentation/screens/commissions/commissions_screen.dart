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
    return LayoutBuilder(
      builder: (ctx, constraints) {
        const double minWidth = 750;
        final bool needsScroll = constraints.maxWidth < minWidth;
        final Widget table = Container(
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
                            ],
                          ),
                        ),
                        Expanded(child: Text(c.offerTitle, style: AppTextStyles.bodyMedium)),
                        Expanded(child: Text('\EGP ${c.amount.toStringAsFixed(0)}', style: AppTextStyles.bodyMedium)),
                        Expanded(child: StatusBadge(label: c.status)),
                        Expanded(child: Text(formatDate(c.dueDate), style: AppTextStyles.bodySmall)),
                        Expanded(child: Text(formatDate(c.earnedAt), style: AppTextStyles.bodySmall)),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
        if (needsScroll) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: minWidth,
              child: table,
            ),
          );
        }
        return table;
      },
    );
  }

}
