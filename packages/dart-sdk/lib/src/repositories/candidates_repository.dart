import '../client/api_client.dart';
import '../models/candidate.dart';
import '../models/pagination.dart';

class CandidatesRepository {
  final ApiClient _api;
  final String _basePath;

  CandidatesRepository({
    required ApiClient apiClient,
    String basePath = '/api/candidates',
  })  : _api = apiClient,
        _basePath = basePath;

  Future<PaginatedResult<Candidate>> list({ListFilter? filter}) async {
    final f = filter ?? const ListFilter();
    final response = await _api.get(_basePath, params: f.toQueryParams());

    List<dynamic> rawList;
    int total;
    int page = f.page;
    int totalPages = 1;

    if (response is List) {
      rawList = response;
      total = rawList.length;
    } else if (response is Map) {
      rawList = response['data'] ?? response['candidates'] ?? response['results'] ?? [];
      total = response['total'] ?? response['count'] ?? rawList.length;
      page = response['page'] ?? f.page;
      totalPages = response['total_pages'] ?? response['totalPages'] ??
          ((total / f.pageSize).ceil());
    } else {
      rawList = [];
      total = 0;
    }

    final candidates = List<Candidate>.from(
      rawList.map((e) => Candidate.fromJson(e as Map<String, dynamic>)),
    );

    return PaginatedResult(
      items: candidates,
      total: total,
      page: page,
      totalPages: totalPages,
    );
  }

  Future<Candidate> getById(String id) async {
    final response = await _api.get('$_basePath/$id');
    return Candidate.fromJson(response as Map<String, dynamic>);
  }

  Future<Candidate> create(Map<String, dynamic> data) async {
    final response = await _api.post(_basePath, body: data);
    return Candidate.fromJson(response as Map<String, dynamic>);
  }

  Future<Candidate> update(String id, Map<String, dynamic> data) async {
    final response = await _api.put('$_basePath/$id', body: data);
    return Candidate.fromJson(response as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _api.delete('$_basePath/$id');
  }

  Future<Candidate> advanceStage(String id) async {
    final response = await _api.patch('$_basePath/$id/advance');
    return Candidate.fromJson(response as Map<String, dynamic>);
  }
}
