// AUTO-GENERATED
import 'candidate_ref.dart';
import 'offer_ref.dart';
class ApplicationWithRelations {
  final CandidateRef candidate;
  final OfferRef offer;

  const ApplicationWithRelations({
    required this.candidate,
    required this.offer,
  });

  factory ApplicationWithRelations.fromJson(Map<String, dynamic> json) =>
    ApplicationWithRelations(
      candidate: CandidateRef.fromJson(json['candidate'] as Map<String, dynamic>),
      offer: OfferRef.fromJson(json['offer'] as Map<String, dynamic>),
    );

  Map<String, dynamic> toJson() => {
    'candidate': candidate.toJson(),
    'offer': offer.toJson(),
  };

  ApplicationWithRelations copyWith({
    CandidateRef? candidate,
    OfferRef? offer,
  }) => ApplicationWithRelations(
    candidate: candidate ?? this.candidate,
    offer: offer ?? this.offer,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is ApplicationWithRelations && other.candidate == candidate && other.offer == offer);
  @override
  int get hashCode => candidate.hashCode ^ offer.hashCode;
}
