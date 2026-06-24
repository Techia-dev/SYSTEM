// AUTO-GENERATED
import 'user_profile.dart';
class MeResponse {
  final UserProfile user;

  const MeResponse({
    required this.user,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) =>
    MeResponse(
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
  };

  MeResponse copyWith({
    UserProfile? user,
  }) => MeResponse(
    user: user ?? this.user,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is MeResponse && other.user == user);
  @override
  int get hashCode => user.hashCode;
}
