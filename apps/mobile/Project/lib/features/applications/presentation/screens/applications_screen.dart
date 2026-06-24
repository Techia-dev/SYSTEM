import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../bloc/applications_bloc.dart';
import '../../../candidates/bloc/candidates_bloc.dart';
import '../../../offers/bloc/offers_bloc.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationsBloc>().add(ApplicationsLoad());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplicationsBloc, ApplicationsState>(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Applications',
                                style: AppTextStyles.displayMedium),
                            const SizedBox(height: 6),
                            const SectionChip(label: 'Recruitment'),
                            const SizedBox(height: 4),
                            Text(state.matchingText,
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      AppPrimaryButton(
                        label: 'New Application',
                        icon: Icons.add,
                        onPressed: () => _showCreateDialog(context),
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
                            child: buildEmpty(context, 'No applications yet')))
                  else
                    ...state.items.map((app) => _buildAppCard(context, app)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppCard(BuildContext context, Application app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.candidateName, style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(app.offerTitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              StatusBadge(status: app.status),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.textMuted),
                onPressed: () => _confirmDelete(context, app.id),
              ),
            ],
          ),
          // const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (app.status == 'applied')
                _actionButton(context, 'Interview',
                    () => _updateStatus(context, app.id, 'interview'))
              else if (app.status == 'interview') ...[
                _actionButton(context, 'Accept',
                    () => _updateStatus(context, app.id, 'accepted'),
                    color: const Color(0xFF047857)),
                const SizedBox(width: 8),
                _actionButton(context, 'Reject',
                    () => _updateStatus(context, app.id, 'rejected'),
                    color: AppColors.error),
              ],
              //   const SizedBox(width: 8),
              //   IconButton(
              //     icon: const Icon(Icons.delete_outline,
              //         size: 18, color: AppColors.textMuted),
              //     onPressed: () => _confirmDelete(context, app.id),
              //   ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
      BuildContext context, String label, VoidCallback onPressed,
      {Color? color}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? AppColors.accentEmerald,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  void _updateStatus(BuildContext context, String id, String status) {
    context.read<ApplicationsBloc>().add(ApplicationsUpdateStatus(id, status));
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<ApplicationsBloc>().add(ApplicationsDelete(id));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final candidatesState = context.read<CandidatesBloc>().state;
    final offersState = context.read<OffersBloc>().state;
    String? selectedCandidateId;
    String? selectedOfferId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Application'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Candidate *'),
                  items: candidatesState.items
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.name} (${c.phone})'),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedCandidateId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Offer *'),
                  items: offersState.items
                      .where((o) => o.isActive)
                      .map((o) => DropdownMenuItem(
                            value: o.id,
                            child: Text(o.title),
                          ))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedOfferId = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: selectedCandidateId != null && selectedOfferId != null
                  ? () {
                      context.read<ApplicationsBloc>().add(ApplicationsCreate({
                            'candidateId': selectedCandidateId,
                            'offerId': selectedOfferId,
                          }));
                      Navigator.pop(ctx);
                    }
                  : null,
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
