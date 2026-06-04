import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/presentation/widgets/candidates/candidate_detail_panel.dart';
import 'package:techia_ats/presentation/widgets/candidates/candidates_table.dart';
import 'package:techia_ats/presentation/widgets/common/common_widgets.dart';
import 'package:techia_ats/presentation/widgets/dashboard/dashboard_widgets.dart';
import 'package:techia_ats/providers/candidates_provider.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidatesProvider>().loadCandidates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 32 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashboardHeader(),
                  const SizedBox(height: 32),
                  _buildStatsRow(constraints.maxWidth),
                  const SizedBox(height: 24),
                  const SearchAndFilterBar(),
                  const SizedBox(height: 24),
                  isDesktop
                      ? _buildDesktopContent()
                      : _buildMobileContent(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsRow(double width) {
    return Consumer<CandidatesProvider>(
      builder: (context, provider, _) {
        final cards = [
          _StatData(
              'Total Candidates',
              provider.totalCount.toString(),
              'Records from the live API'),
          _StatData(
              'Applied',
              provider.appliedCount.toString(),
              'Fresh pipeline entries'),
          _StatData(
              'Interview',
              provider.interviewCount.toString(),
              'Active screening stage'),
          _StatData(
              'Hired',
              provider.hiredCount.toString(),
              'Offers or completed hires'),
        ];

        if (width >= 900) {
          return Row(
            children: cards
                .map((d) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: StatCard(
                          label: d.label,
                          value: d.value,
                          description: d.desc,
                        ),
                      ),
                    ))
                .toList()
              ..last = Expanded(
                child: StatCard(
                  label: cards.last.label,
                  value: cards.last.value,
                  description: cards.last.desc,
                ),
              ),
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: cards
              .map((d) => StatCard(
                    label: d.label,
                    value: d.value,
                    description: d.desc,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildDesktopContent() {
    return Consumer<CandidatesProvider>(
      builder: (context, provider, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              flex: 3,
              child: CandidatesTable(),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: provider.selectedCandidate != null
                  ? CandidateDetailPanel(
                      candidate: provider.selectedCandidate!)
                  : _buildNoSelectionPanel(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileContent() {
    return Consumer<CandidatesProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            const CandidatesTable(),
            if (provider.selectedCandidate != null) ...[
              const SizedBox(height: 16),
              CandidateDetailPanel(candidate: provider.selectedCandidate!),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNoSelectionPanel() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_outline,
              color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text('Select a candidate', style: AppTextStyles.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Click on a candidate from the table to view their details.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final String desc;
  _StatData(this.label, this.value, this.desc);
}
