import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../bloc/candidates_bloc.dart';
import '../widgets/candidates_table.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  String _searchQuery = '';
  String _selectedLevel = 'All levels';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidatesBloc>().add(CandidatesLoad());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CandidatesBloc, CandidatesState>(
      listenWhen: (prev, curr) => curr.error != null && prev.error != curr.error,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.read<CandidatesBloc>().add(CandidatesClearError());
      },
      builder: (context, state) {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Candidates',
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
                        label: 'Add Candidate',
                        icon: Icons.add,
                        onPressed: () => _showAddDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search & Filter
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search candidates...',
                            prefixIcon: Icon(Icons.search, size: 20),
                          ),
                          onChanged: (v) {
                            _searchQuery = v;
                            _applyFilter(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 160,
                        child: DropdownButtonFormField<String>(
                          value: _selectedLevel,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.filter_list, size: 20),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: [
                            'All levels',
                            'Junior',
                            'Mid',
                            'Senior',
                            'Lead'
                          ]
                              .map((l) => DropdownMenuItem(
                                  value: l,
                                  child: Text(l,
                                      style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _selectedLevel = v!);
                            _applyFilter(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Loading / Table
                  if (state.isLoading)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator()))
                  else if (state.items.isEmpty)
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: buildEmpty(context, 'No candidates found')))
                  else ...[
                    CandidatesTable(
                      candidates: state.items,
                      onRefresh: () => context
                          .read<CandidatesBloc>()
                          .add(CandidatesLoad(refresh: true)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _applyFilter(BuildContext context) {
    context.read<CandidatesBloc>().add(CandidatesUpdateFilter(
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
          level: _selectedLevel == 'All levels'
              ? null
              : _selectedLevel.toLowerCase(),
        ));
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedLevel = 'junior';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Candidate'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  textCapitalization: TextCapitalization.words),
              const SizedBox(height: 12),
              TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone *'),
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedLevel,
                decoration: const InputDecoration(labelText: 'Level'),
                items: ['junior', 'mid', 'senior', 'lead']
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => selectedLevel = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                context.read<CandidatesBloc>().add(CandidatesCreate({
                      'name': nameCtrl.text,
                      'phone': phoneCtrl.text,
                      if (emailCtrl.text.isNotEmpty) 'email': emailCtrl.text,
                      'level': selectedLevel,
                    }));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
