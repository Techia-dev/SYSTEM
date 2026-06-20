import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/core/responsive/responsive.dart';
import 'package:techia_ats/presentation/widgets/dashboard/dashboard_widgets.dart';
import 'package:techia_ats/presentation/widgets/common/common_widgets.dart';
import 'package:techia_ats/blocs/candidates/candidates_bloc.dart';
import 'package:techia_ats/blocs/offers/offers_bloc.dart';
import 'package:techia_ats/blocs/commissions/commissions_bloc.dart';

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
      context.read<CandidatesBloc>().add(CandidatesLoad());
      context.read<OffersBloc>().add(OffersLoad());
      context.read<CommissionsBloc>().add(CommissionsLoad());
    });
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
              Text('Overview', style: AppTextStyles.displayMedium),
              const SizedBox(height: 6),
              const SectionChip(label: 'Dashboard'),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              const MonthlyOverviewChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final totalCandidates = context.select<CandidatesBloc, int>((b) => b.state.totalCount);
    final acceptedHired = context.select<CandidatesBloc, int>((b) => b.state.hiredCount);
    final rejected = context.select<CandidatesBloc, int>((b) => b.state.rejectedCount);
    final totalPaid = context.select<CommissionsBloc, double>((b) =>
        b.state.items.where((c) => c.isPaid).fold<double>(0, (sum, c) => sum + c.amount));
    final activeOffers = context.select<OffersBloc, int>((b) =>
        b.state.items.where((o) => o.isActive).length);

    final cards = [
      DashboardStatCard(
        label: 'Total Candidates',
        value: '$totalCandidates',
        subtitle: 'All registered candidates',
      ),
      DashboardStatCard(
        label: 'Collected Commissions',
        value: '${totalPaid.toStringAsFixed(0)} EGP',
        subtitle: 'Total paid out',
      ),
      DashboardStatCard(
        label: 'Accepted',
        value: '$acceptedHired',
        subtitle: 'Candidates hired',
      ),
      DashboardStatCard(
        label: 'Rejected',
        value: '$rejected',
        subtitle: 'Candidates declined',
      ),
      DashboardStatCard(
        label: 'Active Offers',
        value: '$activeOffers',
        subtitle: 'Currently hiring',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 750) {
          return Row(
            children: List.generate(cards.length, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < cards.length - 1 ? 12 : 0),
                  child: cards[i],
                ),
              );
            }),
          );
        }

        if (constraints.maxWidth >= 450) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: cards,
          );
        }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(cards.length, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i < cards.length - 1 ? 12 : 0),
          child: cards[i],
        );
      }),
    );
      },
    );
  }
}
