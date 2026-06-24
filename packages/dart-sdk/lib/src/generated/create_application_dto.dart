// AUTO-GENERATED
class CreateApplicationDto {
  final String candidateId;
  final String offerId;
  final String? source;
  final String? assignedTo;

  const CreateApplicationDto({
    required this.candidateId,
    required this.offerId,
    this.source,
    this.assignedTo,
  });

  factory CreateApplicationDto.fromJson(Map<String, dynamic> json) =>
    CreateApplicationDto(
      candidateId: json['candidateId']?.toString() ?? '',
      offerId: json['offerId']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      assignedTo: json['assignedTo']?.toString() ?? '',
    );

  Map<String, dynamic> toJson() => {
    'candidateId': candidateId,
    'offerId': offerId,
    if (source != null) 'source': source,
    if (assignedTo != null) 'assignedTo': assignedTo,
  };

  CreateApplicationDto copyWith({
    String? candidateId,
    String? offerId,
    String? source,
    String? assignedTo,
  }) => CreateApplicationDto(
    candidateId: candidateId ?? this.candidateId,
    offerId: offerId ?? this.offerId,
    source: source ?? this.source,
    assignedTo: assignedTo ?? this.assignedTo,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is CreateApplicationDto && other.candidateId == candidateId && other.offerId == offerId);
  @override
  int get hashCode => candidateId.hashCode ^ offerId.hashCode;
}
