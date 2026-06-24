// AUTO-GENERATED
class CreateCandidateResponse {
  final String id;
  final String message;

  const CreateCandidateResponse({
    required this.id,
    required this.message,
  });

  factory CreateCandidateResponse.fromJson(Map<String, dynamic> json) =>
    CreateCandidateResponse(
      id: json['id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
  };

  CreateCandidateResponse copyWith({
    String? id,
    String? message,
  }) => CreateCandidateResponse(
    id: id ?? this.id,
    message: message ?? this.message,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is CreateCandidateResponse && other.id == id);
  @override
  int get hashCode => id.hashCode;
}
