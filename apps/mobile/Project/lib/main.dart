import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/candidates/bloc/candidates_bloc.dart';
import 'features/offers/bloc/offers_bloc.dart';
import 'features/applications/bloc/applications_bloc.dart';
import 'features/commissions/bloc/commissions_bloc.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  runApp(const TechiaApp());
}

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
      child: MaterialApp.router(
        title: 'Techia ATS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
