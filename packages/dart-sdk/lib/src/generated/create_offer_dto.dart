// AUTO-GENERATED
class CreateOfferDto {
  final String title;
  final String? company;
  final String? description;
  final num? commission;
  final num? commissionDelay;
  final bool? isActive;

  const CreateOfferDto({
    required this.title,
    this.company,
    this.description,
    this.commission,
    this.commissionDelay,
    this.isActive,
  });

  factory CreateOfferDto.fromJson(Map<String, dynamic> json) =>
    CreateOfferDto(
      title: json['title']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      commission: (json['commission'] as num?) ?? 0,
      commissionDelay: (json['commissionDelay'] as num?) ?? 0,
      isActive: json['isActive'] as bool? ?? false,
    );

  Map<String, dynamic> toJson() => {
    'title': title,
    if (company != null) 'company': company,
    if (description != null) 'description': description,
    if (commission != null) 'commission': commission,
    if (commissionDelay != null) 'commissionDelay': commissionDelay,
    if (isActive != null) 'isActive': isActive,
  };

  CreateOfferDto copyWith({
    String? title,
    String? company,
    String? description,
    num? commission,
    num? commissionDelay,
    bool? isActive,
  }) => CreateOfferDto(
    title: title ?? this.title,
    company: company ?? this.company,
    description: description ?? this.description,
    commission: commission ?? this.commission,
    commissionDelay: commissionDelay ?? this.commissionDelay,
    isActive: isActive ?? this.isActive,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is CreateOfferDto && other.title == title && other.company == company);
  @override
  int get hashCode => title.hashCode ^ company.hashCode;
}
