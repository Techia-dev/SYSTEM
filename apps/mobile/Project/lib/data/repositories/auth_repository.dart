import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/auth_model.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final ApiService _api;

  AuthRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

  Future<AuthModel> login(String email, String password) async {
    final response = await _api.post(
      AppConstants.apiLogin,
      body: {'email': email, 'password': password},
    );

    final auth = AuthModel(
      email: email,
      token: response['token']?.toString() ?? response['access_token']?.toString() ?? '',
      loginTime: DateTime.now(),
    );

    await _saveSession(auth);
    _api.setToken(auth.token);
    return auth;
  }

  Future<AuthModel?> getStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyAuthToken);
    final email = prefs.getString(AppConstants.keyUserEmail);

    if (token != null && email != null) {
      _api.setToken(token);
      return AuthModel(email: email, token: token, loginTime: DateTime.now());
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _api.post(AppConstants.apiLogout);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove(AppConstants.keyUserEmail);
    _api.clearToken();
  }

  Future<void> _saveSession(AuthModel auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAuthToken, auth.token);
    await prefs.setString(AppConstants.keyUserEmail, auth.email);
  }
}
