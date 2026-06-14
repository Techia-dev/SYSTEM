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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidatesBloc>().add(CandidatesLoad());
    }    );
  }

  void _showNewCandidateDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String level = 'Junior';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New candidate'),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name *')),
                  const SizedBox(height: 12),
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone *')),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: level,
                    decoration: const InputDecoration(labelText: 'Level'),
                    items: ['Junior', 'Mid', 'Senior'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => level = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
                context.read<CandidatesBloc>().add(CandidatesCreate({
                  'name': nameCtrl.text,
                  'phone': phoneCtrl.text,
                  'email': emailCtrl.text,
                  'level': level,
                }));
                Navigator.pop(ctx);
              },
              child: const Text('Add candidate'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        BlocBuilder<CandidatesBloc, CandidatesState>(
                          builder: (context, state) {
                            return Text(state.matchingText, style: AppTextStyles.bodySmall);
                          },
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showNewCandidateDialog(),
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
                        items: ['All levels', 'Junior', 'Mid', 'Senior'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: AppTextStyles.bodySmall))).toList(),
                        onChanged: (v) {
                          setState(() => _selectedLevel = v!);
                          context.read<CandidatesBloc>().add(
                            CandidatesUpdateFilter(level: v),
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
    );
  }
}
