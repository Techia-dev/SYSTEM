import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/core/responsive/responsive.dart';
import 'package:techia_ats/blocs/applications/applications_bloc.dart';
import 'package:techia_ats/blocs/candidates/candidates_bloc.dart';
import 'package:techia_ats/blocs/offers/offers_bloc.dart';
import 'package:techia_ats/presentation/widgets/common/common_widgets.dart';

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
    return Stack(
      children: [
        BlocBuilder<ApplicationsBloc, ApplicationsState>(
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
                      if (state.isLoading && state.items.isEmpty)
                        const Center(child: CircularProgressIndicator(color: AppColors.accentEmerald))
                      else if (state.error != null && state.items.isEmpty)
                        buildError(context, state.error!, () =>
                            context.read<ApplicationsBloc>().add(ApplicationsLoad()))
                      else if (state.items.isEmpty)
                        buildEmpty('No applications found')
                      else
                        _buildTable(state.items),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        BlocListener<ApplicationsBloc, ApplicationsState>(
          listenWhen: (prev, curr) =>
              curr.error != null &&
              prev.error != curr.error &&
              prev.items.isNotEmpty &&
              prev.items == curr.items,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ));
          },
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _showNewApplicationDialog() {
    context.read<CandidatesBloc>().add(CandidatesLoad());
    context.read<OffersBloc>().add(OffersLoad());
    showDialog(context: context, builder: (_) => const _CreateApplicationDialog());
  }

  bool _canUpdateStatus(String status) {
    return status == 'applied' || status == 'interview';
  }

  void _showStatusUpdateDialog(Application a) {
    final options = a.status == 'applied'
        ? ['interview', 'rejected']
        : ['accepted', 'rejected'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current: ${a.status[0].toUpperCase()}${a.status.substring(1)}',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 16),
            ...options.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<ApplicationsBloc>().add(ApplicationsUpdateStatus(a.id, s));
                    Navigator.pop(ctx);
                  },
                  child: Text(s[0].toUpperCase() + s.substring(1)),
                ),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _confirmDelete(Application a) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete application'),
        content: Text('Are you sure you want to delete the application for ${a.candidateName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<ApplicationsBloc>().add(ApplicationsDelete(a.id));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusRejected),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<Application> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final a = items[i];
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
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(10),
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
            title: Text(a.candidateName, style: AppTextStyles.titleSmall),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(a.offerTitle, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                StatusBadge(label: a.status),
              ],
            ),
            children: [
              _detailRow(Icons.confirmation_number, 'ID', a.id),
              _detailRow(Icons.work_outline, 'Offer', a.offerTitle),
              _detailRow(Icons.source, 'Source', a.source ?? '—'),
              _detailRow(Icons.calendar_today, 'Applied', formatDate(a.createdAt)),
              _detailRow(Icons.update, 'Updated', formatDate(a.updatedAt)),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_canUpdateStatus(a.status))
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showStatusUpdateDialog(a),
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: const Text('Update status'),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(a),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.statusRejected,
                        side: BorderSide(color: AppColors.statusRejected.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
            width: 80,
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

class _CreateApplicationDialog extends StatefulWidget {
  const _CreateApplicationDialog();

  @override
  State<_CreateApplicationDialog> createState() => _CreateApplicationDialogState();
}

class _CreateApplicationDialogState extends State<_CreateApplicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sourceCtrl = TextEditingController();
  String? _selectedCandidateId;
  String? _selectedOfferId;
  bool _isSubmitting = false;
  bool _didSubmit = false;
  String? _errorMessage;

  @override
  void dispose() {
    _sourceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidates = context.select<CandidatesBloc, List<Candidate>>((b) => b.state.items);
    final offers = context.select<OffersBloc, List<Offer>>((b) => b.state.items);
    final candidatesLoading = context.select<CandidatesBloc, bool>((b) => b.state.isLoading);
    final offersLoading = context.select<OffersBloc, bool>((b) => b.state.isLoading);
    final isLoading = candidatesLoading || offersLoading;

    return BlocListener<ApplicationsBloc, ApplicationsState>(
      listenWhen: (prev, curr) =>
          _didSubmit &&
          !curr.isLoading &&
          (curr.error != null || prev.items != curr.items),
      listener: (context, state) {
        _didSubmit = false;
        setState(() => _isSubmitting = false);
        if (state.error != null) {
          setState(() => _errorMessage = state.error);
        } else {
          Navigator.pop(context);
        }
      },
      child: AlertDialog(
        title: const Text('New application'),
        content: SizedBox(
          width: 360,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assign a candidate to an offer.',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 20),
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                          color: AppColors.accentEmerald),
                    ),
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCandidateId,
                    decoration: const InputDecoration(
                      labelText: 'Candidate *',
                      hintText: 'Select a candidate\u2026',
                    ),
                    items: candidates.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name, overflow: TextOverflow.ellipsis),
                    )).toList(growable: false),
                    onChanged: (v) {
                      setState(() { _selectedCandidateId = v; _errorMessage = null; });
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedOfferId,
                    decoration: const InputDecoration(
                      labelText: 'Offer *',
                      hintText: 'Select an offer\u2026',
                    ),
                    items: offers.map((o) => DropdownMenuItem(
                      value: o.id,
                      child: Text(o.title, overflow: TextOverflow.ellipsis),
                    )).toList(growable: false),
                    onChanged: (v) {
                      setState(() { _selectedOfferId = v; _errorMessage = null; });
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _sourceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Source',
                      hintText: 'LinkedIn, referral, etc.',
                    ),
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.statusRejected.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.statusRejected.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusRejected),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                _isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: (isLoading || _isSubmitting)
                ? null
                : () {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() { _isSubmitting = true; _didSubmit = true; _errorMessage = null; });
                    context.read<ApplicationsBloc>().add(ApplicationsCreate({
                      'candidateId': _selectedCandidateId,
                      'offerId': _selectedOfferId,
                      'source': _sourceCtrl.text,
                    }));
                  },
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child:
                        CircularProgressIndicator(strokeWidth: 2))
                : const Text('Create application'),
          ),
        ],
      ),
    );
  }
}