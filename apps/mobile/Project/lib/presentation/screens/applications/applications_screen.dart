import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/core/responsive/responsive.dart';
import 'package:techia_ats/blocs/applications/applications_bloc.dart';
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
    );
  }

  void _showNewApplicationDialog() {
    final formKey = GlobalKey<FormState>();
    final candidateNameCtrl = TextEditingController();
    final offerTitleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => _ApplicationDialog(
        formKey: formKey,
        candidateNameCtrl: candidateNameCtrl,
        offerTitleCtrl: offerTitleCtrl,
      ),
    );
  }

  Widget _buildTable(List<Application> items) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        const double minWidth = 700;
        final bool needsScroll = constraints.maxWidth < minWidth;
        final Widget table = Container(
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
                Expanded(flex: 2, child: Text('Candidate', style: AppTextStyles.tableHeader)),
                Expanded(flex: 2, child: Text('Offer', style: AppTextStyles.tableHeader)),
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
                            flex: 2,
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
                                Flexible(
                                  child: Text(a.candidateName, style: AppTextStyles.titleSmall, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(a.offerTitle, style: AppTextStyles.bodyMedium, overflow: TextOverflow.ellipsis),
                          ),
                          Expanded(child: StatusBadge(label: a.status)),
                          Expanded(child: Text(formatDate(a.createdAt), style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis)),
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

class _ApplicationDialog extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController candidateNameCtrl;
  final TextEditingController offerTitleCtrl;

  const _ApplicationDialog({
    required this.formKey,
    required this.candidateNameCtrl,
    required this.offerTitleCtrl,
  });

  @override
  State<_ApplicationDialog> createState() => _ApplicationDialogState();
}

class _ApplicationDialogState extends State<_ApplicationDialog> {
  bool _isSubmitting = false;
  bool _didSubmit = false;

  @override
  void dispose() {
    if (!_didSubmit) {
      widget.candidateNameCtrl.dispose();
      widget.offerTitleCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApplicationsBloc, ApplicationsState>(
      listenWhen: (prev, curr) =>
          _didSubmit &&
          !curr.isLoading &&
          (curr.error != null || prev.items != curr.items),
      listener: (context, state) {
        _disposeAll();
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error!),
            backgroundColor: Colors.red,
          ));
          setState(() { _isSubmitting = false; _didSubmit = false; });
        } else {
          Navigator.pop(context);
        }
      },
      child: AlertDialog(
        title: const Text('New application'),
        content: SizedBox(
          width: 360,
          child: Form(
            key: widget.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: widget.candidateNameCtrl,
                  decoration: const InputDecoration(labelText: 'Candidate name *'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: widget.offerTitleCtrl,
                  decoration: const InputDecoration(labelText: 'Offer title *'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    _disposeAll();
                    Navigator.pop(context);
                  },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    if (!widget.formKey.currentState!.validate()) return;
                    setState(() { _isSubmitting = true; _didSubmit = true; });
                    context.read<ApplicationsBloc>().add(ApplicationsCreate({
                      'candidate_name': widget.candidateNameCtrl.text,
                      'offer_title': widget.offerTitleCtrl.text,
                    }));
                  },
            child: _isSubmitting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Add application'),
          ),
        ],
      ),
    );
  }

  void _disposeAll() {
    widget.candidateNameCtrl.dispose();
    widget.offerTitleCtrl.dispose();
  }
}