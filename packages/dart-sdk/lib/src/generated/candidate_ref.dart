// AUTO-GENERATED
class CandidateRef {
  final String? id;
  final String? name;
  final String? phone;
  final String? level;
  const CandidateRef({
    this.id,
    this.name,
    this.phone,
    this.level,
  });
  factory CandidateRef.fromJson(Map<String, dynamic> json) => CandidateRef(
    id: json['id']?.toString(),
    name: json['name']?.toString(),
    phone: json['phone']?.toString(),
    level: json['level']?.toString(),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'level': level,
  };
}
