import '../client/api_client.dart';
import '../models/commission.dart';

class CommissionsRepository {
  final ApiClient _api;
  final String _basePath;

  CommissionsRepository({
    required ApiClient apiClient,
    String basePath = '/api/commissions',
  })  : _api = apiClient,
        _basePath = basePath;

  Future<List<Commission>> list() async {
    final response = await _api.get(_basePath);
    final list = response is List ? response : (response['data'] ?? []);
    return List<Commission>.from(
      list.map((e) => Commission.fromJson(e as Map<String, dynamic>)),
    );
  }

  Future<Commission> getById(String id) async {
    final response = await _api.get('$_basePath/$id');
    return Commission.fromJson(response as Map<String, dynamic>);
  }

  Future<Commission> updateStatus(String id, String status) async {
    final response = await _api.patch('$_basePath/$id/status', body: {'status': status});
    return Commission.fromJson(response as Map<String, dynamic>);
  }
}
