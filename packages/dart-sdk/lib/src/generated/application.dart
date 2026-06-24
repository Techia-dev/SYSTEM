// AUTO-GENERATED
import 'application_status.dart';
class Application {
  final String id;
  final String candidateId;
  final String offerId;
  final ApplicationStatus status;
  final String? source;
  final String? assignedTo;
  final String createdAt;
  final String updatedAt;

  const Application({
    required this.id,
    required this.candidateId,
    required this.offerId,
    required this.status,
    this.source,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) =>
    Application(
      id: json['id']?.toString() ?? '',
      candidateId: json['candidateId']?.toString() ?? '',
      offerId: json['offerId']?.toString() ?? '',
      status: ApplicationStatus.fromJson(json['status']?.toString()),
      source: json['source']?.toString(),
      assignedTo: json['assignedTo']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );

  Map<String, dynamic> toJson() => {
    'id': id,
    'candidateId': candidateId,
    'offerId': offerId,
    'status': status.toJson(),
    'source': source,
    'assignedTo': assignedTo,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  Application copyWith({
    String? id,
    String? candidateId,
    String? offerId,
    ApplicationStatus? status,
    String? source,
    String? assignedTo,
    String? createdAt,
    String? updatedAt,
  }) => Application(
    id: id ?? this.id,
    candidateId: candidateId ?? this.candidateId,
    offerId: offerId ?? this.offerId,
    status: status ?? this.status,
    source: source ?? this.source,
    assignedTo: assignedTo ?? this.assignedTo,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Application && other.id == id);
  @override
  int get hashCode => id.hashCode;
}
