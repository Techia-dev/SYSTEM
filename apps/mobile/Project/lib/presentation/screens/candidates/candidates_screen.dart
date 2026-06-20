import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/core/responsive/responsive.dart';
import 'package:techia_ats/blocs/candidates/candidates_bloc.dart';
import 'package:techia_ats/presentation/widgets/candidates/candidates_table.dart';
import 'add_candidate_screen.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final _searchController = TextEditingController();
  String _selectedLevel = 'All levels';

  static const _levelItems = ['All levels', 'Junior', 'Mid', 'Senior'];
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCandidateScreen()),
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
                        BlocBuilder<CandidatesBloc, CandidatesState>(
                          builder: (context, state) {
                            return Text(state.matchingText, style: AppTextStyles.bodySmall);
                          },
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
      ),
    );
  }
}
