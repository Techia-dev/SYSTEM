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
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

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
              _buildStatsGrid(isDesktop),
              const SizedBox(height: 24),
              const MonthlyOverviewChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(bool isDesktop) {
    return BlocBuilder<CandidatesBloc, CandidatesState>(
      builder: (context, candidatesState) {
        return BlocBuilder<OffersBloc, OffersState>(
          builder: (context, offersState) {
            return BlocBuilder<CommissionsBloc, CommissionsState>(
              builder: (context, commissionsState) {
                final totalPaid = commissionsState.items
                    .where((c) => c.isPaid)
                    .fold<double>(0, (sum, c) => sum + c.amount);
                final acceptedHired = candidatesState.hiredCount;
                final rejected = candidatesState.items
                    .where((c) => c.status == 'rejected')
                    .length;
                final activeOffers = offersState.items
                    .where((o) => o.isActive)
                    .length;

                final cards = [
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

                if (isDesktop) {
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

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: cards,
                );
              },
            );
          },
        );
      },
    );
  }
}
