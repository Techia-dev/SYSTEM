// AUTO-GENERATED
class RegisterDto {
  final String email;
  final String password;
  final String? name;
  final String? role;

  const RegisterDto({
    required this.email,
    required this.password,
    this.name,
    this.role,
  });

  factory RegisterDto.fromJson(Map<String, dynamic> json) =>
    RegisterDto(
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    if (name != null) 'name': name,
    if (role != null) 'role': role,
  };

  RegisterDto copyWith({
    String? email,
    String? password,
    String? name,
    String? role,
  }) => RegisterDto(
    email: email ?? this.email,
    password: password ?? this.password,
    name: name ?? this.name,
    role: role ?? this.role,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is RegisterDto && other.email == email && other.password == password);
  @override
  int get hashCode => email.hashCode ^ password.hashCode;
}
