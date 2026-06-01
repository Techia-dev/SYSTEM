class AuthModel {
  final String email;
  final String token;
  final DateTime loginTime;

  const AuthModel({
    required this.email,
    required this.token,
    required this.loginTime,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      email: json['email']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      loginTime: DateTime.tryParse(json['loginTime']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'token': token,
    'loginTime': loginTime.toIso8601String(),
  };
}
