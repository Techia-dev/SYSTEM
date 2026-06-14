class ListFilter {
  final String? searchQuery;
  final String? status;
  final String? level;
  final int page;
  final int pageSize;

  const ListFilter({
    this.searchQuery,
    this.status,
    this.level,
    this.page = 1,
    this.pageSize = 10,
  });

  ListFilter copyWith({
    String? searchQuery,
    String? status,
    String? level,
    int? page,
    int? pageSize,
  }) {
    return ListFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      level: level ?? this.level,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  Map<String, String> toQueryParams({String? statusAllLabel, String? levelAllLabel}) {
    final params = <String, String>{};
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery!;
    }
    if (status != null && status != (statusAllLabel ?? 'All statuses')) {
      params['status'] = status!;
    }
    if (level != null && level != (levelAllLabel ?? 'All levels')) {
      params['level'] = level!;
    }
    params['page'] = page.toString();
    params['page_size'] = pageSize.toString();
    return params;
  }
}

class PaginatedResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int totalPages;

  const PaginatedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}
