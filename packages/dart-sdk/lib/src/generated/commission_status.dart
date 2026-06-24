// AUTO-GENERATED
enum CommissionStatus {
  pending,
  paid,
  ;
  String toJson() => name;
  factory CommissionStatus.fromJson(String? value) => values.firstWhere((v) => v.name == value, orElse: () => pending);
}
