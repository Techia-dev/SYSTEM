// AUTO-GENERATED
class PaginatedResponse<T> {
  final List<T> data;
  final num total;
  final num page;
  final num pageSize;
  final num totalPages;
  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });
  factory PaginatedResponse.fromJson(Map<String, dynamic> json) =>
    PaginatedResponse(
      data: (json['data'] as List<dynamic>?)?.cast<T>() ?? [],
      total: (json['total'] as num?) ?? 0,
      page: (json['page'] as num?) ?? 0,
      pageSize: (json['pageSize'] as num?) ?? 0,
      totalPages: (json['totalPages'] as num?) ?? 0,
    );
  Map<String, dynamic> toJson() => {
    'data': data,
    'total': total,
    'page': page,
    'pageSize': pageSize,
    'totalPages': totalPages,
  };
}
