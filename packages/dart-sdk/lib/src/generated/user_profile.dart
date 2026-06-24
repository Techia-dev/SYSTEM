// AUTO-GENERATED
class UserProfile {
  final String id;
  final String email;
  final String? name;
  final String role;

  const UserProfile({
    required this.id,
    required this.email,
    this.name,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
    UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString(),
      role: json['role']?.toString() ?? '',
    );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
  };

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
  }) => UserProfile(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name ?? this.name,
    role: role ?? this.role,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is UserProfile && other.id == id);
  @override
  int get hashCode => id.hashCode;
}
