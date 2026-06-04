import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/candidates_provider.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'APPLICANT TRACKING SYSTEM',
                  style: AppTextStyles.labelMedium,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Candidate dashboard',
                style: AppTextStyles.displayLarge,
              ),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMedium,
                  children: [
                    const TextSpan(text: 'Live data from '),
                    TextSpan(
                      text: '/api/candidates',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.textSecondary,
                        backgroundColor: AppColors.bgSurface,
                      ),
                    ),
                    const TextSpan(
                        text: ' with auth, refresh, and stage control.'),
                  ],
                ),
              ),
            ],
          ),
        ),
        _SessionControls(),
      ],
    );
  }
}

class _SessionControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final candidates = context.watch<CandidatesProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SESSION', style: AppTextStyles.labelMedium),
              const SizedBox(height: 2),
              Text(auth.userEmail, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => candidates.loadCandidates(refresh: true),
              child: const Text('Refresh'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => auth.logout(),
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SearchAndFilterBar extends StatefulWidget {
  const SearchAndFilterBar({super.key});

  @override
  State<SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<SearchAndFilterBar> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'All statuses';
  String _selectedLevel = 'All levels';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CandidatesProvider>();
    final isMobile = context.isMobile;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: isMobile
              ? _buildMobileFilters(provider)
              : _buildDesktopFilters(provider),
        ),
        const SizedBox(height: 8),
        _buildFilterFooter(),
      ],
    );
  }

  Widget _buildDesktopFilters(CandidatesProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Search', style: AppTextStyles.bodySmall),
              const SizedBox(height: 6),
              TextField(
                controller: _searchController,
                onChanged: (v) => provider.updateFilter(searchQuery: v),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Search by name, phone, email, level, or id',
                  prefixIcon:
                      Icon(Icons.search, color: AppColors.textMuted, size: 18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status', style: AppTextStyles.bodySmall),
              const SizedBox(height: 6),
              _DropdownFilter(
                value: _selectedStatus,
                items: AppConstants.statusFilters,
                onChanged: (v) {
                  setState(() => _selectedStatus = v!);
                  provider.updateFilter(status: v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Level', style: AppTextStyles.bodySmall),
              const SizedBox(height: 6),
              _DropdownFilter(
                value: _selectedLevel,
                items: AppConstants.candidateLevels,
                onChanged: (v) {
                  setState(() => _selectedLevel = v!);
                  provider.updateFilter(level: v);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFilters(CandidatesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Search', style: AppTextStyles.bodySmall),
        const SizedBox(height: 6),
        TextField(
          controller: _searchController,
          onChanged: (v) => provider.updateFilter(searchQuery: v),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search candidates...',
            prefixIcon:
                Icon(Icons.search, color: AppColors.textMuted, size: 18),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 6),
                  _DropdownFilter(
                    value: _selectedStatus,
                    items: AppConstants.statusFilters,
                    onChanged: (v) {
                      setState(() => _selectedStatus = v!);
                      provider.updateFilter(status: v);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Level', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 6),
                  _DropdownFilter(
                    value: _selectedLevel,
                    items: AppConstants.candidateLevels,
                    onChanged: (v) {
                      setState(() => _selectedLevel = v!);
                      provider.updateFilter(level: v);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterFooter() {
    return Consumer<CandidatesProvider>(
      builder: (context, provider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(provider.matchingText, style: AppTextStyles.bodySmall),
            if (provider.lastSynced != null)
              Text(
                DateUtils.formatSynced(provider.lastSynced!),
                style: AppTextStyles.bodySmall,
              ),
          ],
        );
      },
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownFilter({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      dropdownColor: AppColors.bgCardElevated,
      decoration: const InputDecoration(),
      items: items
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
