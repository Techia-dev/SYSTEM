// AUTO-GENERATED
class LogoutResponse {
  final String message;

  const LogoutResponse({
    required this.message,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) =>
    LogoutResponse(
      message: json['message']?.toString() ?? '',
    );

  Map<String, dynamic> toJson() => {
    'message': message,
  };

  LogoutResponse copyWith({
    String? message,
  }) => LogoutResponse(
    message: message ?? this.message,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is LogoutResponse && other.message == message);
  @override
  int get hashCode => message.hashCode;
}
