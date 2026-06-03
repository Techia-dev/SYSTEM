import '../services/api_service.dart';
import '../models/candidate_model.dart';
import '../models/candidate_filter_model.dart';
import '../../core/constants/app_constants.dart';

class CandidatesRepository {
  final ApiService _api;

  CandidatesRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

  Future<CandidatesResult> getCandidates(CandidateFilter filter) async {
    final response = await _api.get(
      AppConstants.apiCandidates,
      params: filter.toQueryParams(),
    );

    List<dynamic> rawList = [];
    int total = 0;
    int page = filter.page;
    int totalPages = 1;

    if (response is List) {
      rawList = response;
      total = rawList.length;
    } else if (response is Map) {
      rawList = response['data'] ?? response['candidates'] ?? response['results'] ?? [];
      total = response['total'] ?? response['count'] ?? rawList.length;
      page = response['page'] ?? filter.page;
      totalPages = response['total_pages'] ?? response['totalPages'] ??
          ((total / filter.pageSize).ceil());
    }

    final candidates = rawList.map((e) => Candidate.fromJson(e as Map<String, dynamic>)).toList();

    return CandidatesResult(
      candidates: candidates,
      total: total,
      page: page,
      totalPages: totalPages,
    );
  }

  Future<Candidate> getCandidateById(String id) async {
    final response = await _api.get('${AppConstants.apiCandidates}/$id');
    return Candidate.fromJson(response as Map<String, dynamic>);
  }

  Future<Candidate> advanceCandidateStage(String id) async {
    final path = AppConstants.apiAdvanceStage.replaceAll('{id}', id);
    final response = await _api.patch(path);
    return Candidate.fromJson(response as Map<String, dynamic>);
  }

  Map<String, int> getCandidateStats(List<Candidate> candidates) {
    return {
      'total': candidates.length,
      'applied': candidates.where((c) => c.status == AppConstants.stageApplied).length,
      'interview': candidates.where((c) => c.status == AppConstants.stageInterview).length,
      'hired': candidates.where((c) => c.status == AppConstants.stageHired).length,
    };
  }
}
