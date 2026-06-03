class CandidateFilter {
  final String? searchQuery;
  final String? status;
  final String? level;
  final int page;
  final int pageSize;

  const CandidateFilter({
    this.searchQuery,
    this.status,
    this.level,
    this.page = 1,
    this.pageSize = 10,
  });

  CandidateFilter copyWith({
    String? searchQuery,
    String? status,
    String? level,
    int? page,
    int? pageSize,
  }) {
    return CandidateFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      level: level ?? this.level,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery!;
    }
    if (status != null && status != 'All statuses') {
      params['status'] = status!;
    }
    if (level != null && level != 'All levels') {
      params['level'] = level!;
    }
    params['page'] = page.toString();
    params['page_size'] = pageSize.toString();
    return params;
  }
}

class CandidatesResult {
  final List<dynamic> candidates;
  final int total;
  final int page;
  final int totalPages;

  const CandidatesResult({
    required this.candidates,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}
