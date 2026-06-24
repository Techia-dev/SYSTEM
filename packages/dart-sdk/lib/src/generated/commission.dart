// AUTO-GENERATED
import 'commission_status.dart';
class Commission {
  final String id;
  final String applicationId;
  final String offerId;
  final String candidateId;
  final num amount;
  final CommissionStatus status;
  final String earnedAt;
  final String dueDate;
  final String createdAt;
  final String updatedAt;

  const Commission({
    required this.id,
    required this.applicationId,
    required this.offerId,
    required this.candidateId,
    required this.amount,
    required this.status,
    required this.earnedAt,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Commission.fromJson(Map<String, dynamic> json) =>
    Commission(
      id: json['id']?.toString() ?? '',
      applicationId: json['applicationId']?.toString() ?? '',
      offerId: json['offerId']?.toString() ?? '',
      candidateId: json['candidateId']?.toString() ?? '',
      amount: (json['amount'] as num?) ?? 0,
      status: CommissionStatus.fromJson(json['status']?.toString()),
      earnedAt: json['earnedAt']?.toString() ?? '',
      dueDate: json['dueDate']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );

  Map<String, dynamic> toJson() => {
    'id': id,
    'applicationId': applicationId,
    'offerId': offerId,
    'candidateId': candidateId,
    'amount': amount,
    'status': status.toJson(),
    'earnedAt': earnedAt,
    'dueDate': dueDate,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  Commission copyWith({
    String? id,
    String? applicationId,
    String? offerId,
    String? candidateId,
    num? amount,
    CommissionStatus? status,
    String? earnedAt,
    String? dueDate,
    String? createdAt,
    String? updatedAt,
  }) => Commission(
    id: id ?? this.id,
    applicationId: applicationId ?? this.applicationId,
    offerId: offerId ?? this.offerId,
    candidateId: candidateId ?? this.candidateId,
    amount: amount ?? this.amount,
    status: status ?? this.status,
    earnedAt: earnedAt ?? this.earnedAt,
    dueDate: dueDate ?? this.dueDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Commission && other.id == id);
  @override
  int get hashCode => id.hashCode;
}
