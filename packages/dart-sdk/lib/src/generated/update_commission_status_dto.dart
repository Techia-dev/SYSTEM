// AUTO-GENERATED
import 'commission_status.dart';
class UpdateCommissionStatusDto {
  final CommissionStatus status;

  const UpdateCommissionStatusDto({
    required this.status,
  });

  factory UpdateCommissionStatusDto.fromJson(Map<String, dynamic> json) =>
    UpdateCommissionStatusDto(
      status: CommissionStatus.fromJson(json['status']?.toString()),
    );

  Map<String, dynamic> toJson() => {
    'status': status.toJson(),
  };

  UpdateCommissionStatusDto copyWith({
    CommissionStatus? status,
  }) => UpdateCommissionStatusDto(
    status: status ?? this.status,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is UpdateCommissionStatusDto && other.status == status);
  @override
  int get hashCode => status.hashCode;
}
