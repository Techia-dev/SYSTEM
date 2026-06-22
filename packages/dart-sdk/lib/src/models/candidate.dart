class Candidate {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? alternativePhone;
  final String level;
  final String? qualification;
  final String? experience;
  final String? cvUrl;
  final String status;
  final String createdAt;

  const Candidate({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.alternativePhone,
    required this.level,
    this.qualification,
    this.experience,
    this.cvUrl,
    required this.status,
    required this.createdAt,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      alternativePhone: json['alternative_phone']?.toString() ?? json['alternativePhone']?.toString(),
      level: json['level']?.toString() ?? '',
      qualification: json['qualification']?.toString(),
      experience: json['experience']?.toString(),
      cvUrl: json['cv_url']?.toString() ?? json['cvUrl']?.toString(),
      status: json['status']?.toString() ?? 'applied',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'alternative_phone': alternativePhone,
    'level': level,
    'qualification': qualification,
    'experience': experience,
    'cv_url': cvUrl,
    'status': status,
    'created_at': createdAt,
  };

  Candidate copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? alternativePhone,
    String? level,
    String? qualification,
    String? experience,
    String? cvUrl,
    String? status,
    String? createdAt,
  }) {
    return Candidate(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      alternativePhone: alternativePhone ?? this.alternativePhone,
      level: level ?? this.level,
      qualification: qualification ?? this.qualification,
      experience: experience ?? this.experience,
      cvUrl: cvUrl ?? this.cvUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get displayPhone => phone.isEmpty ? 'No phone' : phone;
  String get displayEmail => (email == null || email!.isEmpty) ? 'Not provided' : email!;
  bool get hasEmail => email != null && email!.isNotEmpty;
  bool get hasCv => cvUrl != null && cvUrl!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Candidate && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
