// AUTO-GENERATED
class LoginDto {
  final String email;
  final String password;

  const LoginDto({
    required this.email,
    required this.password,
  });

  factory LoginDto.fromJson(Map<String, dynamic> json) =>
    LoginDto(
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
    );

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };

  LoginDto copyWith({
    String? email,
    String? password,
  }) => LoginDto(
    email: email ?? this.email,
    password: password ?? this.password,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is LoginDto && other.email == email && other.password == password);
  @override
  int get hashCode => email.hashCode ^ password.hashCode;
}
