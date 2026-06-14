class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class LoginResponse {
  final String token;
  final String? accessToken;
  final String? email;
  final String? role;

  const LoginResponse({
    required this.token,
    this.accessToken,
    this.email,
    this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token']?.toString() ??
        json['access_token']?.toString() ?? '';
    return LoginResponse(
      token: token,
      accessToken: json['access_token']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
    );
  }

  String get effectiveToken => accessToken ?? token;
}

class AuthSession {
  final String email;
  final String token;
  final DateTime loginTime;

  const AuthSession({
    required this.email,
    required this.token,
    required this.loginTime,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      email: json['email']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      loginTime: DateTime.tryParse(json['loginTime']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'token': token,
    'loginTime': loginTime.toIso8601String(),
  };
}
