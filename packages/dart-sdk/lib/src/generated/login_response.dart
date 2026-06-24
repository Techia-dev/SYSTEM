// AUTO-GENERATED
import 'user_profile.dart';
class LoginResponse {
  final String token;
  final String expiresIn;
  final UserProfile user;

  const LoginResponse({
    required this.token,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
    LoginResponse(
      token: json['token']?.toString() ?? '',
      expiresIn: json['expiresIn']?.toString() ?? '',
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );

  Map<String, dynamic> toJson() => {
    'token': token,
    'expiresIn': expiresIn,
    'user': user.toJson(),
  };

  LoginResponse copyWith({
    String? token,
    String? expiresIn,
    UserProfile? user,
  }) => LoginResponse(
    token: token ?? this.token,
    expiresIn: expiresIn ?? this.expiresIn,
    user: user ?? this.user,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is LoginResponse && other.token == token && other.expiresIn == expiresIn);
  @override
  int get hashCode => token.hashCode ^ expiresIn.hashCode;
}
