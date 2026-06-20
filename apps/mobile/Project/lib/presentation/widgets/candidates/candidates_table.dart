import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/blocs/candidates/candidates_bloc.dart';
import 'package:techia_ats/presentation/widgets/common/common_widgets.dart';

class CandidatesTable extends StatelessWidget {
  const CandidatesTable({super.key});

  static final _levelMenuItems = ['Junior', 'Mid', 'Senior']
      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CandidatesBloc, CandidatesState>(
      builder: (context, state) {
        if (state.isLoading && state.items.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.accentEmerald));
        }
        if (state.error != null && state.items.isEmpty) {
          return buildError(context, state.error!,
              () => context.read<CandidatesBloc>().add(CandidatesLoad()));
        }
        if (state.items.isEmpty) {
          return buildEmpty('No candidates found');
        }

        return LayoutBuilder(
          builder: (ctx, constraints) {
            const double minWidth = 900;
            final bool needsScroll = constraints.maxWidth < minWidth;
            final Widget table = Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildHeader(state),
                  _buildTable(context, state),
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
      },
    );
  }

  Widget _buildHeader(CandidatesState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Text('Candidate', style: AppTextStyles.tableHeader),
          const SizedBox(width: 8),
          Expanded(child: Text('Phone', style: AppTextStyles.tableHeader)),
          Expanded(child: Text('Level', style: AppTextStyles.tableHeader)),
          Expanded(
              child: Text('Qualification', style: AppTextStyles.tableHeader)),
          Expanded(child: Text('Experience', style: AppTextStyles.tableHeader)),
          Expanded(child: Text('CV', style: AppTextStyles.tableHeader)),
          Expanded(child: Text('Joined', style: AppTextStyles.tableHeader)),
          const SizedBox(width: 160),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, CandidatesState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, index) {
        final c = state.items[index];
        final isSelected = state.selected?.id == c.id;
        return Container(
          color: isSelected ? AppColors.bgSecondary : null,
          child: InkWell(
            onTap: () =>
                context.read<CandidatesBloc>().add(CandidatesSelect(c)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Initials avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accentEmerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.accentEmerald,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: AppTextStyles.titleSmall),
                        Text(c.displayEmail, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  // Phone
                  Expanded(
                    child:
                        Text(c.displayPhone, style: AppTextStyles.bodyMedium),
                  ),
                  // Level
                  Expanded(
                    child: Text(
                      c.level.isEmpty ? '—' : c.level,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  // Qualification (not in model, show dash)
                  Expanded(
                    child: Text('—', style: AppTextStyles.bodySmall),
                  ),
                  // Experience (not in model, show dash)
                  Expanded(
                    child: Text('—', style: AppTextStyles.bodySmall),
                  ),
                  // CV
                  Expanded(
                    child: Text('—', style: AppTextStyles.bodySmall),
                  ),
                  // Joined
                  Expanded(
                    child: Text(formatDate(c.createdAt),
                        style: AppTextStyles.bodySmall),
                  ),
                  // Actions
                  SizedBox(
                    width: 160,
                    child: Row(
                      children: [
                        _ActionButton(
                            label: 'Edit',
                            onTap: () => _editCandidate(context, c)),
                        const SizedBox(width: 4),
                        _ActionButton(label: 'CV', onTap: () {}),
                        const SizedBox(width: 4),
                        _ActionButton(
                            label: 'Delete',
                            onTap: () => _deleteCandidate(context, c),
                            destructive: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _editCandidate(BuildContext context, Candidate c) {
    final nameCtrl = TextEditingController(text: c.name);
    final phoneCtrl = TextEditingController(text: c.phone);
    final emailCtrl = TextEditingController(text: c.email ?? '');
    String level = c.level;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit candidate'),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: level,
                    decoration: const InputDecoration(labelText: 'Level'),
                    items: _levelMenuItems,
                    onChanged: (v) => setState(() => level = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                context.read<CandidatesBloc>().add(CandidatesUpdate(c.id, {
                      'name': nameCtrl.text,
                      'phone': phoneCtrl.text,
                      'email': emailCtrl.text,
                      'level': level.toLowerCase(),
                    }));
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCandidate(BuildContext context, Candidate c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete candidate'),
        content: Text('Are you sure you want to delete ${c.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<CandidatesBloc>().add(CandidatesDelete(c.id));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusRejected),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
              color: destructive
                  ? AppColors.statusRejected.withValues(alpha: 0.3)
                  : AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: destructive
                ? AppColors.statusRejected
                : AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
