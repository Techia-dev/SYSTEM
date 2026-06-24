// AUTO-GENERATED
import 'candidate.dart';
class ListCandidatesResponse {
  final List<Candidate> data;
  final num total;
  final num page;
  final num pageSize;
  final num totalPages;

  const ListCandidatesResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory ListCandidatesResponse.fromJson(Map<String, dynamic> json) =>
    ListCandidatesResponse(
      data: (json['data'] as List<dynamic>?)?.map((e) => Candidate.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      total: (json['total'] as num?) ?? 0,
      page: (json['page'] as num?) ?? 0,
      pageSize: (json['pageSize'] as num?) ?? 0,
      totalPages: (json['totalPages'] as num?) ?? 0,
    );

  Map<String, dynamic> toJson() => {
    'data': data.toList(),
    'total': total,
    'page': page,
    'pageSize': pageSize,
    'totalPages': totalPages,
  };

  ListCandidatesResponse copyWith({
    List<Candidate>? data,
    num? total,
    num? page,
    num? pageSize,
    num? totalPages,
  }) => ListCandidatesResponse(
    data: data ?? this.data,
    total: total ?? this.total,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    totalPages: totalPages ?? this.totalPages,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || (other is ListCandidatesResponse && other.data == data && other.total == total);
  @override
  int get hashCode => data.hashCode ^ total.hashCode;
}
