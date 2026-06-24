import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_routes.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'shared/widgets/main_scaffold.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => const _SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (_, __) => const MainScaffold(),
    ),
  ],
);

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AuthBloc>().add(AuthCheckSession()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.dashboard);
        } else if (state is AuthUnauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
        ),
      ),
    );
  }
}
