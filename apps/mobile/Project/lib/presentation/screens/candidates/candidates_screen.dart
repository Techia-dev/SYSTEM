import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/core/responsive/responsive.dart';
import 'package:techia_ats/blocs/candidates/candidates_bloc.dart';
import 'package:techia_ats/presentation/widgets/candidates/candidates_table.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final _searchController = TextEditingController();
  String _selectedLevel = 'All levels';

  static const _levelItems = ['All levels', 'Junior', 'Mid', 'Senior', 'Lead'];
  static final _levelMenuItems = _levelItems.map((s) =>
    DropdownMenuItem(value: s, child: Text(s, style: AppTextStyles.bodySmall))
  ).toList(growable: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidatesBloc>().add(CandidatesLoad());
    }    );
  }

  void _openAddCandidate() {
    showDialog(
      context: context,
      builder: (_) => const _AddCandidateDialog(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CandidatesBloc, CandidatesState>(
      listenWhen: (prev, curr) => curr.error != null && prev.error != curr.error && prev.lastSynced == curr.lastSynced,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(state.error!),
          backgroundColor: Colors.red,
        ));
      },
      child: Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: screenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Candidates', style: AppTextStyles.headlineLarge),
                        const SizedBox(height: 4),
                        Text(
                          context.select<CandidatesBloc, String>((b) => b.state.matchingText),
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openAddCandidate,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New candidate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentEmerald,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Search & Filter
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => context.read<CandidatesBloc>().add(
                        CandidatesUpdateFilter(searchQuery: v),
                      ),
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Search name, phone, email\u2026',
                        prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLevel,
                        isExpanded: true,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                        items: _levelMenuItems,
                        onChanged: (v) {
                          final selected = v;
                          if (selected == null) return;
                          setState(() => _selectedLevel = selected);
                          context.read<CandidatesBloc>().add(
                            CandidatesUpdateFilter(
                              level: selected == 'All levels' ? 'All levels' : selected.toLowerCase(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Candidates Table
              const CandidatesTable(),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _AddCandidateDialog extends StatefulWidget {
  const _AddCandidateDialog();

  @override
  State<_AddCandidateDialog> createState() => _AddCandidateDialogState();
}

class _AddCandidateDialogState extends State<_AddCandidateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _selectedLevel = 'Junior';
  bool _isSubmitting = false;
  bool _didSubmit = false;

  static const _levelItems = ['Junior', 'Mid', 'Senior', 'Lead'];
  static final _levelMenuItems = _levelItems.map((s) =>
    DropdownMenuItem(value: s, child: Text(s, style: AppTextStyles.bodyMedium))
  ).toList(growable: false);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CandidatesBloc, CandidatesState>(
      listenWhen: (prev, curr) =>
          _didSubmit &&
          !curr.isLoading &&
          (curr.error != null || prev.lastSynced != curr.lastSynced),
      listener: (context, state) {
        _didSubmit = false;
        setState(() => _isSubmitting = false);
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error!),
            backgroundColor: Colors.red,
          ));
        } else {
          Navigator.pop(context);
        }
      },
      child: AlertDialog(
        title: const Text('New candidate'),
        content: SizedBox(
          width: min(MediaQuery.sizeOf(context).width * 0.9, isDesktop(context) ? 480 : (isTablet(context) ? 420 : 360)),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fill in the candidate details.', style: AppTextStyles.bodySmall),
                const SizedBox(height: 16),
                Text('Name *', style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _nameCtrl,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  decoration: const InputDecoration(hintText: 'Full name'),
                ),
                const SizedBox(height: 12),
                Text('Phone *', style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  decoration: const InputDecoration(hintText: '+20 100 123 4567'),
                ),
                const SizedBox(height: 12),
                Text('Email', style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'email@example.com'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                    if (!emailRegex.hasMatch(v)) return 'Invalid email format';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text('Level', style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLevel,
                  items: _levelMenuItems,
                  onChanged: (v) => setState(() => _selectedLevel = v!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Add candidate'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSubmitting = true; _didSubmit = true; });
    context.read<CandidatesBloc>().add(CandidatesCreate({
      'name': _nameCtrl.text,
      'phone': _phoneCtrl.text,
      'email': _emailCtrl.text,
      'level': _selectedLevel.toLowerCase(),
    }));
  }
}
