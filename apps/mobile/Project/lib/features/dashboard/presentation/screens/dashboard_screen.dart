import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../candidates/bloc/candidates_bloc.dart';
import '../../../offers/bloc/offers_bloc.dart';
import '../../../commissions/bloc/commissions_bloc.dart';
import '../widgets/dashboard_widgets.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => curr is AuthUnauthenticated,
      listener: (context, _) => context.go('/login'),
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: screenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Overview', style: AppTextStyles.displayMedium),
                          const SizedBox(height: 6),
                          const SectionChip(label: 'Dashboard'),
                        ],
                      ),
                    ),
                    AppOutlinedButton(
                      label: 'Logout',
                      icon: Icons.logout,
                      color: AppColors.error,
                      onPressed: () => context.read<AuthBloc>().add(AuthLogout()),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                const CandidatesStatusChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final acceptedHired =
        context.select<CandidatesBloc, int>((b) => b.state.hiredCount);
    final rejected =
        context.select<CandidatesBloc, int>((b) => b.state.rejectedCount);
    final totalPaid = context.select<CommissionsBloc, double>((b) => b
        .state.items
        .where((c) => c.isPaid)
        .fold<double>(0, (sum, c) => sum + c.amount));
    final activeOffers = context.select<OffersBloc, int>(
        (b) => b.state.items.where((o) => o.isActive).length);

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = constraints.maxWidth < 450 ? 8.0 : 12.0;
        final useSingleRow = constraints.maxWidth >= 700;

        if (useSingleRow) {
          return Row(children: [
            Expanded(child: DashboardStatCard(label: 'Commissions', value: '${totalPaid.toStringAsFixed(0)} EGP', subtitle: 'Total paid out')),
            SizedBox(width: gap),
            Expanded(child: DashboardStatCard(label: 'Active Offers', value: '$activeOffers', subtitle: 'Currently hiring')),
            SizedBox(width: gap),
            Expanded(child: DashboardStatCard(label: 'Accepted', value: '$acceptedHired', subtitle: 'Candidates hired')),
            SizedBox(width: gap),
            Expanded(child: DashboardStatCard(label: 'Rejected', value: '$rejected', subtitle: 'Candidates declined')),
          ]);
        }

        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: DashboardStatCard(label: 'Commissions', value: '${totalPaid.toStringAsFixed(0)} EGP', subtitle: 'Total paid out')),
            SizedBox(width: gap),
            Expanded(child: DashboardStatCard(label: 'Active Offers', value: '$activeOffers', subtitle: 'Currently hiring')),
          ]),
          SizedBox(height: gap),
          Row(children: [
            Expanded(child: DashboardStatCard(label: 'Accepted', value: '$acceptedHired', subtitle: 'Candidates hired')),
            SizedBox(width: gap),
            Expanded(child: DashboardStatCard(label: 'Rejected', value: '$rejected', subtitle: 'Candidates declined')),
          ]),
        ]);
      },
    );
  }
}
