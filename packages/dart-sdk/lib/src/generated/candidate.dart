// AUTO-GENERATED
import 'candidate_level.dart';
class Candidate {
  final String id;
  final String name;
  final String phone;
  final String? secondaryPhone;
  final String? email;
  final CandidateLevel level;
  final String? qualification;
  final String? experience;
  final String? cvUrl;
  final String createdAt;
  final String updatedAt;

  const Candidate({
    required this.id,
    required this.name,
    required this.phone,
    this.secondaryPhone,
    this.email,
    required this.level,
    this.qualification,
    this.experience,
    this.cvUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) =>
    Candidate(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      secondaryPhone: json['secondaryPhone']?.toString(),
      email: json['email']?.toString(),
      level: CandidateLevel.fromJson(json['level']?.toString()),
      qualification: json['qualification']?.toString(),
      experience: json['experience']?.toString(),
      cvUrl: json['cvUrl']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'secondaryPhone': secondaryPhone,
    'email': email,
    'level': level.toJson(),
    'qualification': qualification,
    'experience': experience,
    'cvUrl': cvUrl,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  Candidate copyWith({
    String? id,
    String? name,
    String? phone,
    String? secondaryPhone,
    String? email,
    CandidateLevel? level,
    String? qualification,
    String? experience,
    String? cvUrl,
    String? createdAt,
    String? updatedAt,
  }) => Candidate(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    secondaryPhone: secondaryPhone ?? this.secondaryPhone,
    email: email ?? this.email,
    level: level ?? this.level,
    qualification: qualification ?? this.qualification,
    experience: experience ?? this.experience,
    cvUrl: cvUrl ?? this.cvUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Candidate && other.id == id);
  @override
  int get hashCode => id.hashCode;
}
