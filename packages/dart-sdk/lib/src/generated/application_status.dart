// AUTO-GENERATED
enum ApplicationStatus {
  applied,
  interview,
  accepted,
  rejected,
  ;
  String toJson() => name;
  factory ApplicationStatus.fromJson(String? value) => values.firstWhere((v) => v.name == value, orElse: () => applied);
}
