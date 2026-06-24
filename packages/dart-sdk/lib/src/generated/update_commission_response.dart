// AUTO-GENERATED
import 'commission_status.dart';
class UpdateCommissionResponse {
  final String id;
  final CommissionStatus status;
  final String message;

  const UpdateCommissionResponse({
    required this.id,
    required this.status,
    required this.message,
  });

  factory UpdateCommissionResponse.fromJson(Map<String, dynamic> json) =>
    UpdateCommissionResponse(
      id: json['id']?.toString() ?? '',
      status: CommissionStatus.fromJson(json['status']?.toString()),
      message: json['message']?.toString() ?? '',
    );

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status.toJson(),
    'message': message,
  };

  UpdateCommissionResponse copyWith({
    String? id,
    CommissionStatus? status,
    String? message,
  }) => UpdateCommissionResponse(
    id: id ?? this.id,
    status: status ?? this.status,
    message: message ?? this.message,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is UpdateCommissionResponse && other.id == id);
  @override
  int get hashCode => id.hashCode;
}
