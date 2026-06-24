// AUTO-GENERATED
class DashboardStats {
  final num totalCollectedCommissions;
  final num totalAcceptedCandidates;
  final num totalRejectedCandidates;

  const DashboardStats({
    required this.totalCollectedCommissions,
    required this.totalAcceptedCandidates,
    required this.totalRejectedCandidates,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
    DashboardStats(
      totalCollectedCommissions: (json['totalCollectedCommissions'] as num?) ?? 0,
      totalAcceptedCandidates: (json['totalAcceptedCandidates'] as num?) ?? 0,
      totalRejectedCandidates: (json['totalRejectedCandidates'] as num?) ?? 0,
    );

  Map<String, dynamic> toJson() => {
    'totalCollectedCommissions': totalCollectedCommissions,
    'totalAcceptedCandidates': totalAcceptedCandidates,
    'totalRejectedCandidates': totalRejectedCandidates,
  };

  DashboardStats copyWith({
    num? totalCollectedCommissions,
    num? totalAcceptedCandidates,
    num? totalRejectedCandidates,
  }) => DashboardStats(
    totalCollectedCommissions: totalCollectedCommissions ?? this.totalCollectedCommissions,
    totalAcceptedCandidates: totalAcceptedCandidates ?? this.totalAcceptedCandidates,
    totalRejectedCandidates: totalRejectedCandidates ?? this.totalRejectedCandidates,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is DashboardStats && other.totalCollectedCommissions == totalCollectedCommissions && other.totalAcceptedCandidates == totalAcceptedCandidates);
  @override
  int get hashCode => totalCollectedCommissions.hashCode ^ totalAcceptedCandidates.hashCode;
}
