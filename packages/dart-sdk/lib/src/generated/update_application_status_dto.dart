// AUTO-GENERATED
import 'application_status.dart';
class UpdateApplicationStatusDto {
  final ApplicationStatus status;

  const UpdateApplicationStatusDto({
    required this.status,
  });

  factory UpdateApplicationStatusDto.fromJson(Map<String, dynamic> json) =>
    UpdateApplicationStatusDto(
      status: ApplicationStatus.fromJson(json['status']?.toString()),
    );

  Map<String, dynamic> toJson() => {
    'status': status.toJson(),
  };

  UpdateApplicationStatusDto copyWith({
    ApplicationStatus? status,
  }) => UpdateApplicationStatusDto(
    status: status ?? this.status,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is UpdateApplicationStatusDto && other.status == status);
  @override
  int get hashCode => status.hashCode;
}
