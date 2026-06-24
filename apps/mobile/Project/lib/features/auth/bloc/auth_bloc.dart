import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techia_sdk/techia_sdk.dart';
import '../../../core/constants/app_constants.dart';
import '../../../di/injection_container.dart';

sealed class AuthEvent {}

final class AuthCheckSession extends AuthEvent {}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;
  AuthLogin(this.email, this.password);
}

final class AuthLogout extends AuthEvent {}

final class AuthSessionExpired extends AuthEvent {}

final class AuthClearError extends AuthEvent {}

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {
  final AuthSession session;
  AuthAuthenticated(this.session);
}

final class AuthUnauthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  final SharedPreferences _prefs;

  AuthBloc({AuthRepository? repository, SharedPreferences? prefs})
      : _repository = repository ?? sl<AuthRepository>(),
        _prefs = prefs ?? sl<SharedPreferences>(),
        super(AuthInitial()) {
    ApiClient.onUnauthorized = _handleUnauthorized;
    on<AuthCheckSession>(_onCheckSession);
    on<AuthLogin>(_onLogin);
    on<AuthLogout>(_onLogout);
    on<AuthSessionExpired>(_onSessionExpired);
    on<AuthClearError>(_onClearError);
  }

  Future<void> _handleUnauthorized() async {
    await _prefs.remove(AppConstants.keyAuthToken);
    await _prefs.remove(AppConstants.keyUserEmail);
    if (state is AuthAuthenticated) {
      add(AuthSessionExpired());
    }
  }

  Future<void> _onCheckSession(AuthCheckSession event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = _prefs.getString(AppConstants.keyAuthToken);
      final email = _prefs.getString(AppConstants.keyUserEmail);
      if (token != null && email != null) {
        sl<ApiClient>().setToken(token);
        final me = await _repository.getMe();
        if (me != null) {
          emit(AuthAuthenticated(AuthSession(email: email, token: token, loginTime: DateTime.now())));
        } else {
          await _prefs.remove(AppConstants.keyAuthToken);
          await _prefs.remove(AppConstants.keyUserEmail);
          sl<ApiClient>().clearToken();
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      await _prefs.remove(AppConstants.keyAuthToken);
      await _prefs.remove(AppConstants.keyUserEmail);
      sl<ApiClient>().clearToken();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _repository.login(event.email, event.password);
      final session = AuthSession(
        email: event.email,
        token: response.effectiveToken,
        loginTime: DateTime.now(),
      );
      await _prefs.setString(AppConstants.keyAuthToken, session.token);
      await _prefs.setString(AppConstants.keyUserEmail, session.email);
      emit(AuthAuthenticated(session));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await _repository.logout();
    await _prefs.remove(AppConstants.keyAuthToken);
    await _prefs.remove(AppConstants.keyUserEmail);
    emit(AuthUnauthenticated());
  }

  void _onSessionExpired(AuthSessionExpired event, Emitter<AuthState> emit) {
    emit(AuthUnauthenticated());
  }

  void _onClearError(AuthClearError event, Emitter<AuthState> emit) {
    if (state is AuthError) emit(AuthUnauthenticated());
  }
}
