class Candidate {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String level;
  final String status;
  final String createdAt;

  const Candidate({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.level,
    required this.status,
    required this.createdAt,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      level: json['level']?.toString() ?? '',
      status: json['status']?.toString() ?? 'applied',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'level': level,
    'status': status,
    'created_at': createdAt,
  };

  Candidate copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? level,
    String? status,
    String? createdAt,
  }) {
    return Candidate(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      level: level ?? this.level,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get displayPhone => phone.isEmpty ? 'No phone' : phone;
  String get displayEmail => (email == null || email!.isEmpty) ? 'Not provided' : email!;
  bool get hasEmail => email != null && email!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Candidate && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
