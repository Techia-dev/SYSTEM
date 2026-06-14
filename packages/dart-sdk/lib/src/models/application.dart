class Application {
  final String id;
  final String candidateId;
  final String offerId;
  final String candidateName;
  final String offerTitle;
  final String status;
  final String? source;
  final String? assignedTo;
  final String createdAt;
  final String updatedAt;

  const Application({
    required this.id,
    required this.candidateId,
    required this.offerId,
    this.candidateName = '',
    this.offerTitle = '',
    required this.status,
    this.source,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id']?.toString() ?? '',
      candidateId: json['candidateId']?.toString() ?? '',
      offerId: json['offerId']?.toString() ?? '',
      candidateName: json['candidate']?['name']?.toString() ??
          json['candidateName']?.toString() ?? '',
      offerTitle: json['offer']?['title']?.toString() ??
          json['offerTitle']?.toString() ?? '',
      status: json['status']?.toString() ?? 'applied',
      source: json['source']?.toString(),
      assignedTo: json['assignedTo']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'candidateId': candidateId,
    'offerId': offerId,
    'status': status,
    'source': source,
    'assignedTo': assignedTo,
  };

  Application copyWith({
    String? id,
    String? candidateId,
    String? offerId,
    String? candidateName,
    String? offerTitle,
    String? status,
    String? source,
    String? assignedTo,
    String? createdAt,
    String? updatedAt,
  }) {
    return Application(
      id: id ?? this.id,
      candidateId: candidateId ?? this.candidateId,
      offerId: offerId ?? this.offerId,
      candidateName: candidateName ?? this.candidateName,
      offerTitle: offerTitle ?? this.offerTitle,
      status: status ?? this.status,
      source: source ?? this.source,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Application && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
