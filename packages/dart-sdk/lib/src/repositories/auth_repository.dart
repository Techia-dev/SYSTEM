import '../client/api_client.dart';
import '../models/auth.dart';

class AuthRepository {
  final ApiClient _api;
  final String _loginPath;
  final String _logoutPath;
  final String _mePath;

  AuthRepository({
    required ApiClient apiClient,
    String loginPath = '/api/auth/login',
    String logoutPath = '/api/auth/logout',
    String mePath = '/api/auth/me',
  })  : _api = apiClient,
        _loginPath = loginPath,
        _logoutPath = logoutPath,
        _mePath = mePath;

  Future<LoginResponse> login(String email, String password) async {
    final response = await _api.post(
      _loginPath,
      body: {'email': email, 'password': password},
    );

    final loginResponse = LoginResponse.fromJson(response as Map<String, dynamic>);
    _api.setToken(loginResponse.effectiveToken);
    return loginResponse;
  }

  Future<void> logout() async {
    try {
      await _api.post(_logoutPath);
    } catch (_) {}
    _api.clearToken();
  }

  Future<Map<String, dynamic>?> getMe() async {
    try {
      final response = await _api.get(_mePath);
      return response as Map<String, dynamic>?;
    } on ApiException {
      return null;
    }
  }
}
