import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techia_sdk/techia_sdk.dart';
import '../../core/network.dart';
import '../../core/constants/app_constants.dart';

sealed class AuthEvent {}

final class AuthCheckSession extends AuthEvent {}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;
  AuthLogin(this.email, this.password);
}

final class AuthLogout extends AuthEvent {}

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

  AuthBloc({AuthRepository? repository})
      : _repository = repository ?? AuthRepository(apiClient: apiClient),
        super(AuthInitial()) {
    on<AuthCheckSession>(_onCheckSession);
    on<AuthLogin>(_onLogin);
    on<AuthLogout>(_onLogout);
    on<AuthClearError>(_onClearError);
  }

  Future<void> _onCheckSession(AuthCheckSession event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyAuthToken);
      final email = prefs.getString(AppConstants.keyUserEmail);
      if (token != null && email != null) {
        apiClient.setToken(token);
        emit(AuthAuthenticated(AuthSession(email: email, token: token, loginTime: DateTime.now())));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyAuthToken, session.token);
      await prefs.setString(AppConstants.keyUserEmail, session.email);
      emit(AuthAuthenticated(session));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await _repository.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove(AppConstants.keyUserEmail);
    emit(AuthUnauthenticated());
  }

  void _onClearError(AuthClearError event, Emitter<AuthState> emit) {
    if (state is AuthError) emit(AuthUnauthenticated());
  }
}
