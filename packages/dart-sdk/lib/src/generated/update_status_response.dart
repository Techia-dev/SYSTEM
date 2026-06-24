// AUTO-GENERATED
class UpdateStatusResponse {
  final bool success;
  final String message;

  const UpdateStatusResponse({
    required this.success,
    required this.message,
  });

  factory UpdateStatusResponse.fromJson(Map<String, dynamic> json) =>
    UpdateStatusResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
    );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
  };

  UpdateStatusResponse copyWith({
    bool? success,
    String? message,
  }) => UpdateStatusResponse(
    success: success ?? this.success,
    message: message ?? this.message,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is UpdateStatusResponse && other.success == success && other.message == message);
  @override
  int get hashCode => success.hashCode ^ message.hashCode;
}
