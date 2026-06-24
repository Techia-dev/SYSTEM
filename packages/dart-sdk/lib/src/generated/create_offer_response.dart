// AUTO-GENERATED
class CreateOfferResponse {
  final String id;
  final String message;

  const CreateOfferResponse({
    required this.id,
    required this.message,
  });

  factory CreateOfferResponse.fromJson(Map<String, dynamic> json) =>
    CreateOfferResponse(
      id: json['id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
  };

  CreateOfferResponse copyWith({
    String? id,
    String? message,
  }) => CreateOfferResponse(
    id: id ?? this.id,
    message: message ?? this.message,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is CreateOfferResponse && other.id == id);
  @override
  int get hashCode => id.hashCode;
}
