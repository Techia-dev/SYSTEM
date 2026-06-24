// AUTO-GENERATED
import 'candidate.dart';
import 'commission.dart';
import 'offer.dart';
class ApplicationFull {
  final Candidate candidate;
  final Offer offer;
  final Commission? commission;

  const ApplicationFull({
    required this.candidate,
    required this.offer,
    this.commission,
  });

  factory ApplicationFull.fromJson(Map<String, dynamic> json) =>
    ApplicationFull(
      candidate: Candidate.fromJson(json['candidate'] as Map<String, dynamic>),
      offer: Offer.fromJson(json['offer'] as Map<String, dynamic>),
      commission: json['commission'] != null ? Commission.fromJson(json['commission'] as Map<String, dynamic>) : null,
    );

  Map<String, dynamic> toJson() => {
    'candidate': candidate.toJson(),
    'offer': offer.toJson(),
    'commission': commission?.toJson(),
  };

  ApplicationFull copyWith({
    Candidate? candidate,
    Offer? offer,
    Commission? commission,
  }) => ApplicationFull(
    candidate: candidate ?? this.candidate,
    offer: offer ?? this.offer,
    commission: commission ?? this.commission,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is ApplicationFull && other.candidate == candidate && other.offer == offer);
  @override
  int get hashCode => candidate.hashCode ^ offer.hashCode;
}
