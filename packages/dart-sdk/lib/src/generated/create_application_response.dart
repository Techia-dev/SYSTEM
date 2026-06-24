// AUTO-GENERATED
class CreateApplicationResponse {
  final String id;
  final String message;

  const CreateApplicationResponse({
    required this.id,
    required this.message,
  });

  factory CreateApplicationResponse.fromJson(Map<String, dynamic> json) =>
    CreateApplicationResponse(
      id: json['id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
  };

  CreateApplicationResponse copyWith({
    String? id,
    String? message,
  }) => CreateApplicationResponse(
    id: id ?? this.id,
    message: message ?? this.message,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is CreateApplicationResponse && other.id == id);
  @override
  int get hashCode => id.hashCode;
}
