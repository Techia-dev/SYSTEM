class Offer {
  final String id;
  final String title;
  final String? company;
  final String? description;
  final double commission;
  final int commissionDelay;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const Offer({
    required this.id,
    required this.title,
    this.company,
    this.description,
    required this.commission,
    required this.commissionDelay,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      company: json['company']?.toString(),
      description: json['description']?.toString(),
      commission: (json['commission'] as num?)?.toDouble() ?? 0.0,
      commissionDelay: json['commissionDelay'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'company': company,
    'description': description,
    'commission': commission,
    'commissionDelay': commissionDelay,
    'isActive': isActive,
  };

  Offer copyWith({
    String? id,
    String? title,
    String? company,
    String? description,
    double? commission,
    int? commissionDelay,
    bool? isActive,
  }) {
    return Offer(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      description: description ?? this.description,
      commission: commission ?? this.commission,
      commissionDelay: commissionDelay ?? this.commissionDelay,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Offer && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
