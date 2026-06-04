class Commission {
  final String id;
  final String applicationId;
  final String offerId;
  final String candidateId;
  final String candidateName;
  final String offerTitle;
  final double amount;
  final String status;
  final String earnedAt;
  final String dueDate;
  final String createdAt;

  const Commission({
    required this.id,
    required this.applicationId,
    required this.offerId,
    required this.candidateId,
    this.candidateName = '',
    this.offerTitle = '',
    required this.amount,
    required this.status,
    required this.earnedAt,
    required this.dueDate,
    required this.createdAt,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      id: json['id']?.toString() ?? '',
      applicationId: json['applicationId']?.toString() ?? '',
      offerId: json['offerId']?.toString() ?? '',
      candidateId: json['candidateId']?.toString() ?? '',
      candidateName: json['candidate']?['name']?.toString() ?? json['candidateName']?.toString() ?? '',
      offerTitle: json['offer']?['title']?.toString() ?? json['offerTitle']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      earnedAt: json['earnedAt']?.toString() ?? '',
      dueDate: json['dueDate']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  bool get isPaid => status == 'paid';
  bool get isOverdue {
    final due = DateTime.tryParse(dueDate);
    return due != null && due.isBefore(DateTime.now()) && !isPaid;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Commission && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
