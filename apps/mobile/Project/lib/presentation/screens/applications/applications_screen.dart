import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/core/responsive/responsive.dart';
import 'package:techia_ats/blocs/applications/applications_bloc.dart';

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
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Applications', style: AppTextStyles.headlineLarge),
                            const SizedBox(height: 4),
                            Text(state.matchingText, style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showNewApplicationDialog(),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('New application'),
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

  void _showNewApplicationDialog() {
    final candidateNameCtrl = TextEditingController();
    final offerTitleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New application'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: candidateNameCtrl, decoration: const InputDecoration(labelText: 'Candidate name *')),
              const SizedBox(height: 12),
              TextField(controller: offerTitleCtrl, decoration: const InputDecoration(labelText: 'Offer title *')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (candidateNameCtrl.text.isEmpty || offerTitleCtrl.text.isEmpty) return;
              context.read<ApplicationsBloc>().add(ApplicationsCreate({
                'candidate_name': candidateNameCtrl.text,
                'offer_title': offerTitleCtrl.text,
              }));
              Navigator.pop(ctx);
            },
            child: const Text('Add application'),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<Application> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(child: Text('Candidate', style: AppTextStyles.tableHeader)),
                Expanded(child: Text('Offer', style: AppTextStyles.tableHeader)),
                Expanded(child: Text('Status', style: AppTextStyles.tableHeader)),
                Expanded(child: Text('Applied', style: AppTextStyles.tableHeader)),
              ],
            ),
          ),
          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (_, i) {
              final a = items[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.bgSecondary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              a.candidateName.isNotEmpty ? a.candidateName[0].toUpperCase() : '?',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(a.candidateName, style: AppTextStyles.titleSmall),
                        ],
                      ),
                    ),
                    Expanded(child: Text(a.offerTitle, style: AppTextStyles.bodyMedium)),
                    Expanded(child: _StatusBadge(a.status)),
                    Expanded(child: Text(_formatDate(a.createdAt), style: AppTextStyles.bodySmall)),
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
    final isAccepted = status.toLowerCase() == 'accepted';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAccepted ? AppColors.accentEmerald.withValues(alpha: 0.1) : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: AppTextStyles.bodySmall.copyWith(
          color: isAccepted ? AppColors.accentEmerald : AppColors.textSecondary,
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
            onPressed: () => context.read<ApplicationsBloc>().add(ApplicationsLoad()),
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
      child: const Center(child: Text('No applications found', style: AppTextStyles.bodyMedium)),
    );
  }
}
