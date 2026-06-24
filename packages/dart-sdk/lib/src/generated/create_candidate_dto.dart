// AUTO-GENERATED
import 'candidate_level.dart';
class CreateCandidateDto {
  final String name;
  final String phone;
  final String? email;
  final CandidateLevel? level;

  const CreateCandidateDto({
    required this.name,
    required this.phone,
    this.email,
    this.level,
  });

  factory CreateCandidateDto.fromJson(Map<String, dynamic> json) =>
    CreateCandidateDto(
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      level: CandidateLevel.fromJson(json['level']?.toString()),
    );

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    if (email != null) 'email': email,
    if (level != null) 'level': level?.toJson(),
  };

  CreateCandidateDto copyWith({
    String? name,
    String? phone,
    String? email,
    CandidateLevel? level,
  }) => CreateCandidateDto(
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    level: level ?? this.level,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is CreateCandidateDto && other.name == name && other.phone == phone);
  @override
  int get hashCode => name.hashCode ^ phone.hashCode;
}
