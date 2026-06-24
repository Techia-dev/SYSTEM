// AUTO-GENERATED
import 'candidate_level.dart';
class UpdateCandidateDto {
  final String? name;
  final String? phone;
  final String? secondaryPhone;
  final String? email;
  final CandidateLevel? level;
  final String? qualification;
  final String? experience;
  final String? cvUrl;

  const UpdateCandidateDto({
    this.name,
    this.phone,
    this.secondaryPhone,
    this.email,
    this.level,
    this.qualification,
    this.experience,
    this.cvUrl,
  });

  factory UpdateCandidateDto.fromJson(Map<String, dynamic> json) =>
    UpdateCandidateDto(
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      secondaryPhone: json['secondaryPhone']?.toString(),
      email: json['email']?.toString(),
      level: CandidateLevel.fromJson(json['level']?.toString()),
      qualification: json['qualification']?.toString(),
      experience: json['experience']?.toString(),
      cvUrl: json['cvUrl']?.toString(),
    );

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (phone != null) 'phone': phone,
    'secondaryPhone': secondaryPhone,
    'email': email,
    if (level != null) 'level': level?.toJson(),
    'qualification': qualification,
    'experience': experience,
    'cvUrl': cvUrl,
  };

  UpdateCandidateDto copyWith({
    String? name,
    String? phone,
    String? secondaryPhone,
    String? email,
    CandidateLevel? level,
    String? qualification,
    String? experience,
    String? cvUrl,
  }) => UpdateCandidateDto(
    name: name ?? this.name,
    phone: phone ?? this.phone,
    secondaryPhone: secondaryPhone ?? this.secondaryPhone,
    email: email ?? this.email,
    level: level ?? this.level,
    qualification: qualification ?? this.qualification,
    experience: experience ?? this.experience,
    cvUrl: cvUrl ?? this.cvUrl,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is UpdateCandidateDto && other.name == name && other.phone == phone);
  @override
  int get hashCode => name.hashCode ^ phone.hashCode;
}
