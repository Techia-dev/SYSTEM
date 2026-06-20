import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:techia_sdk/techia_sdk.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/blocs/candidates/candidates_bloc.dart';
import 'package:techia_ats/presentation/widgets/common/common_widgets.dart';

class CandidatesTable extends StatelessWidget {
  const CandidatesTable({super.key});

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

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _CandidateCard(candidate: state.items[index]);
          },
        );
      },
    );
  }
}

class _CandidateCard extends StatefulWidget {
  final Candidate candidate;
  const _CandidateCard({required this.candidate});

  @override
  State<_CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends State<_CandidateCard> {
  static final _levelMenuItems = ['Junior', 'Mid', 'Senior', 'Lead']
      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
      .toList(growable: false);

  static String _normalizeLevel(String level) {
    switch (level.toLowerCase()) {
      case 'junior': return 'Junior';
      case 'mid': return 'Mid';
      case 'senior': return 'Senior';
      case 'lead': return 'Lead';
      default: return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.candidate;
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
            color: AppColors.accentEmerald.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
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
        title: Text(c.name, style: AppTextStyles.titleSmall),
        subtitle: Row(
          children: [
            LevelBadge(level: c.level),
            const SizedBox(width: 8),
            StatusBadge(label: c.status),
          ],
        ),
        children: [
          _detailRow(Icons.phone_outlined, 'Phone', c.displayPhone),
          if (c.alternativePhone != null && c.alternativePhone!.isNotEmpty)
            _detailRow(Icons.phone, 'Alt Phone', c.alternativePhone!),
          _detailRow(Icons.email_outlined, 'Email', c.displayEmail),
          _detailRow(Icons.school_outlined, 'Qualification',
              c.qualification?.isNotEmpty == true ? c.qualification! : '—'),
          _detailRow(Icons.work_outline, 'Experience',
              c.experience?.isNotEmpty == true ? c.experience! : '—'),
          _detailRow(Icons.description_outlined, 'CV',
              c.hasCv ? 'Uploaded' : 'Not uploaded',
              valueColor: c.hasCv ? AppColors.statusActive : null),
          _detailRow(Icons.calendar_today, 'Joined', formatDate(c.createdAt)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editCandidate(c),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child:               OutlinedButton.icon(
                  onPressed: _pickAndUploadCv,
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('CV'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteCandidate(c),
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
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? valueColor}) {
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
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(color: valueColor ?? AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _editCandidate(Candidate c) {
    final nameCtrl = TextEditingController(text: c.name);
    final phoneCtrl = TextEditingController(text: c.phone);
    final altPhoneCtrl = TextEditingController(text: c.alternativePhone ?? '');
    final emailCtrl = TextEditingController(text: c.email ?? '');
    final qualCtrl = TextEditingController(text: c.qualification ?? '');
    final expCtrl = TextEditingController(text: c.experience ?? '');
    String level = _normalizeLevel(c.level);

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
                      decoration: const InputDecoration(labelText: 'Full name')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: altPhoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Alternative phone',
                        hintText: 'Optional',
                      )),
                  const SizedBox(height: 12),
                  TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _levelMenuItems.any((i) => i.value == level) ? level : null,
                    decoration: const InputDecoration(labelText: 'Level'),
                    items: _levelMenuItems,
                    onChanged: (v) => setState(() => level = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                      controller: qualCtrl,
                      decoration: const InputDecoration(labelText: 'Qualification')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: expCtrl,
                      decoration: const InputDecoration(labelText: 'Experience')),
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
                      'alternative_phone': altPhoneCtrl.text,
                      'email': emailCtrl.text,
                      'level': level.toLowerCase(),
                      'qualification': qualCtrl.text,
                      'experience': expCtrl.text,
                    }));
                Navigator.pop(ctx);
              },
              child: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickAndUploadCv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.path == null) return;
      if (!mounted) return;
      context.read<CandidatesBloc>().add(CandidatesUploadCv(widget.candidate.id, file.path!));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  void _deleteCandidate(Candidate c) {
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
