import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:techia_sdk/techia_sdk.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../bloc/candidates_bloc.dart';

class CandidatesTable extends StatelessWidget {
  final List<Candidate> candidates;
  final VoidCallback? onRefresh;
  const CandidatesTable({super.key, required this.candidates, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: candidates.map((c) => _CandidateCard(candidate: c, onRefresh: onRefresh)).toList(),
    );
  }
}

class _CandidateCard extends StatefulWidget {
  final Candidate candidate;
  final VoidCallback? onRefresh;
  const _CandidateCard({required this.candidate, this.onRefresh});

  @override
  State<_CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends State<_CandidateCard> {
  @override
  Widget build(BuildContext context) {
    final c = widget.candidate;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            CandidateAvatar(name: c.name, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 2),
                  Text(c.phone, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            LevelBadge(level: c.level),
            const SizedBox(width: 8),
            if (c.hasCv)
              const Icon(Icons.description_outlined, size: 16, color: AppColors.textMuted),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(label: 'Email', value: c.displayEmail),
                InfoRow(label: 'Phone', value: c.phone),
                InfoRow(label: 'Level', value: c.level),
                InfoRow(label: 'Qualification', value: c.qualification ?? '—'),
                InfoRow(label: 'Experience', value: c.experience ?? '—'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppOutlinedButton(
                      label: 'Edit',
                      icon: Icons.edit_outlined,
                      onPressed: () => _showEditDialog(context, c),
                    ),
                    const SizedBox(width: 8),
                    AppOutlinedButton(
                      label: 'Upload CV',
                      icon: Icons.upload_file_outlined,
                      onPressed: () => _pickAndUploadCv(context, c.id),
                    ),
                    const SizedBox(width: 8),
                    AppOutlinedButton(
                      label: 'Delete',
                      icon: Icons.delete_outline,
                      color: AppColors.error,
                      onPressed: () => _confirmDelete(context, c.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Candidate c) {
    final nameCtrl = TextEditingController(text: c.name);
    final phoneCtrl = TextEditingController(text: c.phone);
    final emailCtrl = TextEditingController(text: c.email ?? '');
    String level = c.level;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Candidate'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name'), textCapitalization: TextCapitalization.words),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: level,
                decoration: const InputDecoration(labelText: 'Level'),
                items: ['junior', 'mid', 'senior', 'lead'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (v) => level = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<CandidatesBloc>().add(CandidatesUpdate(c.id, {
                'name': nameCtrl.text,
                'phone': phoneCtrl.text,
                if (emailCtrl.text.isNotEmpty) 'email': emailCtrl.text,
                'level': level,
              }));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadCv(BuildContext context, String id) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        context.read<CandidatesBloc>().add(CandidatesUploadCv(id, result.files.single.path!));
      }
    }
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Candidate'),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<CandidatesBloc>().add(CandidatesDelete(id));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
