// AUTO-GENERATED
class MonthlyAnalytics {
  final String month;
  final num accepted;
  final num rejected;
  final num paidCommissions;
  final num pendingCommissions;

  const MonthlyAnalytics({
    required this.month,
    required this.accepted,
    required this.rejected,
    required this.paidCommissions,
    required this.pendingCommissions,
  });

  factory MonthlyAnalytics.fromJson(Map<String, dynamic> json) =>
    MonthlyAnalytics(
      month: json['month']?.toString() ?? '',
      accepted: (json['accepted'] as num?) ?? 0,
      rejected: (json['rejected'] as num?) ?? 0,
      paidCommissions: (json['paidCommissions'] as num?) ?? 0,
      pendingCommissions: (json['pendingCommissions'] as num?) ?? 0,
    );

  Map<String, dynamic> toJson() => {
    'month': month,
    'accepted': accepted,
    'rejected': rejected,
    'paidCommissions': paidCommissions,
    'pendingCommissions': pendingCommissions,
  };

  MonthlyAnalytics copyWith({
    String? month,
    num? accepted,
    num? rejected,
    num? paidCommissions,
    num? pendingCommissions,
  }) => MonthlyAnalytics(
    month: month ?? this.month,
    accepted: accepted ?? this.accepted,
    rejected: rejected ?? this.rejected,
    paidCommissions: paidCommissions ?? this.paidCommissions,
    pendingCommissions: pendingCommissions ?? this.pendingCommissions,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is MonthlyAnalytics && other.month == month && other.accepted == accepted);
  @override
  int get hashCode => month.hashCode ^ accepted.hashCode;
}
