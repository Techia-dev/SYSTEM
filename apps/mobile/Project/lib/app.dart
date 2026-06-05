import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/candidates_provider.dart';
import 'providers/offers_provider.dart';
import 'providers/applications_provider.dart';
import 'providers/commissions_provider.dart';
import 'app_router.dart';

class TechiaApp extends StatelessWidget {
  const TechiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CandidatesProvider()),
        ChangeNotifierProvider(create: (_) => OffersProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationsProvider()),
        ChangeNotifierProvider(create: (_) => CommissionsProvider()),
      ],
      child: MaterialApp(
        title: 'Techia ATS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
