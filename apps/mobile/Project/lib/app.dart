import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/candidates/candidates_bloc.dart';
import 'blocs/offers/offers_bloc.dart';
import 'blocs/applications/applications_bloc.dart';
import 'blocs/commissions/commissions_bloc.dart';
import 'app_router.dart';

class TechiaApp extends StatelessWidget {
  const TechiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => CandidatesBloc()),
        BlocProvider(create: (_) => OffersBloc()),
        BlocProvider(create: (_) => ApplicationsBloc()),
        BlocProvider(create: (_) => CommissionsBloc()),
      ],
      child: MaterialApp(
        title: 'Techia ATS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
