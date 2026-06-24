// AUTO-GENERATED
class OfferRef {
  final String? id;
  final String? title;
  final String? company;
  final String? commission;
  const OfferRef({
    this.id,
    this.title,
    this.company,
    this.commission,
  });
  factory OfferRef.fromJson(Map<String, dynamic> json) => OfferRef(
    id: json['id']?.toString(),
    title: json['title']?.toString(),
    company: json['company']?.toString(),
    commission: json['commission']?.toString(),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'company': company,
    'commission': commission,
  };
}
