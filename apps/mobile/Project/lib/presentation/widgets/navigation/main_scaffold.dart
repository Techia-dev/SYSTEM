import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/candidates/candidates_screen.dart';
import '../../screens/offers/offers_screen.dart';
import '../../screens/applications/applications_screen.dart';
import '../../screens/commissions/commissions_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    CandidatesScreen(),
    ApplicationsScreen(),
    OffersScreen(),
    CommissionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1024;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated && mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Row(
          children: [
            if (isDesktop) _buildSidebar(),
            Expanded(
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
          ],
        ),
        bottomNavigationBar: isDesktop ? null : _buildBottomNav(),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Logo & Brand
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.accentEmerald,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.people_alt_outlined, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text('Techia', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 42),
                  child: Text('ATS System', style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
                ),
              ],
            ),
          ),
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _SectionHeader('Overview'),
                _NavItem(
                  icon: Icons.grid_view_outlined,
                  label: 'Dashboard',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                const SizedBox(height: 16),
                _SectionHeader('Recruitment'),
                _NavItem(
                  icon: Icons.people_outline,
                  label: 'Candidates',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.assignment_outlined,
                  label: 'Applications',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.work_outline,
                  label: 'Offers',
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                const SizedBox(height: 16),
                _SectionHeader('Finance'),
                _NavItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Commissions',
                  isSelected: _currentIndex == 4,
                  onTap: () => setState(() => _currentIndex = 4),
                ),
              ],
            ),
          ),
          // Sign out
          const Divider(height: 1, color: AppColors.border),
          InkWell(
            onTap: () => context.read<AuthBloc>().add(AuthLogout()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.logout, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text('Sign out', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.bgCard,
        selectedItemColor: AppColors.accentEmerald,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Candidates'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Applications'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), activeIcon: Icon(Icons.work), label: 'Offers'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Commissions'),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 4),
      child: Text(label.toUpperCase(), style: AppTextStyles.labelMedium),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.sidebarActive : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.sidebarActiveText : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.sidebarActiveText : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
