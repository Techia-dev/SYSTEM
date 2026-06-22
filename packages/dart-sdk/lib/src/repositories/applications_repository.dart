import '../client/api_client.dart';
import '../models/application.dart';

class ApplicationsRepository {
  final ApiClient _api;
  final String _basePath;

  ApplicationsRepository({
    required ApiClient apiClient,
    String basePath = '/api/applications',
  })  : _api = apiClient,
        _basePath = basePath;

  Future<List<Application>> list() async {
    final response = await _api.get(_basePath);
    final list = response is List ? response : (response['data'] ?? []);
    return List<Application>.from(
      list.map((e) => Application.fromJson(e as Map<String, dynamic>)),
    );
  }

  Future<Application> getById(String id) async {
    final response = await _api.get('$_basePath/$id');
    return Application.fromJson(response as Map<String, dynamic>);
  }

  Future<Application> create(Map<String, dynamic> data) async {
    final response = await _api.post(_basePath, body: data);
    return Application.fromJson(response as Map<String, dynamic>);
  }

  Future<Application> updateStatus(String id, String status) async {
    final response = await _api.put('$_basePath/$id/status', body: {'status': status});
    return Application.fromJson(response as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _api.delete('$_basePath/$id');
  }
}
