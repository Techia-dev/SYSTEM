import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_routes.dart';
import 'blocs/auth/auth_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/widgets/navigation/main_scaffold.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => const MainScaffold(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const _SplashScreen(),
          settings: settings,
        );
    }
  }
}

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
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        } else if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
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
