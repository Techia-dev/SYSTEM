// AUTO-GENERATED
import 'candidate_ref.dart';
import 'offer_ref.dart';
class CommissionWithRelations {
  final CandidateRef candidate;
  final OfferRef offer;

  const CommissionWithRelations({
    required this.candidate,
    required this.offer,
  });

  factory CommissionWithRelations.fromJson(Map<String, dynamic> json) =>
    CommissionWithRelations(
      candidate: CandidateRef.fromJson(json['candidate'] as Map<String, dynamic>),
      offer: OfferRef.fromJson(json['offer'] as Map<String, dynamic>),
    );

  Map<String, dynamic> toJson() => {
    'candidate': candidate.toJson(),
    'offer': offer.toJson(),
  };

  CommissionWithRelations copyWith({
    CandidateRef? candidate,
    OfferRef? offer,
  }) => CommissionWithRelations(
    candidate: candidate ?? this.candidate,
    offer: offer ?? this.offer,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is CommissionWithRelations && other.candidate == candidate && other.offer == offer);
  @override
  int get hashCode => candidate.hashCode ^ offer.hashCode;
}
