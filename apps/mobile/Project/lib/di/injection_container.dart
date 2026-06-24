import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techia_sdk/techia_sdk.dart';
import '../core/constants/app_constants.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  final apiClient = ApiClient(baseUrl: AppConstants.baseUrl);
  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<ApiClient>(() => apiClient);
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(apiClient: apiClient));
  sl.registerLazySingleton<CandidatesRepository>(() => CandidatesRepository(apiClient: apiClient));
  sl.registerLazySingleton<OffersRepository>(() => OffersRepository(apiClient: apiClient));
  sl.registerLazySingleton<ApplicationsRepository>(() => ApplicationsRepository(apiClient: apiClient));
  sl.registerLazySingleton<CommissionsRepository>(() => CommissionsRepository(apiClient: apiClient));
}
