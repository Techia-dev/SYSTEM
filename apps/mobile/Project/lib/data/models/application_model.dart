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
      candidateName: json['candidate']?['name']?.toString() ?? json['candidateName']?.toString() ?? '',
      offerTitle: json['offer']?['title']?.toString() ?? json['offerTitle']?.toString() ?? '',
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Application && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
