// AUTO-GENERATED
enum CandidateLevel {
  junior,
  mid,
  senior,
  lead,
  ;
  String toJson() => name;
  factory CandidateLevel.fromJson(String? value) => values.firstWhere((v) => v.name == value, orElse: () => junior);
}
