import '../services/api_service.dart';
import '../models/application_model.dart';
import '../../core/constants/app_constants.dart';

class ApplicationsRepository {
  final ApiService _api;

  ApplicationsRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

  Future<List<Application>> getApplications() async {
    final response = await _api.get(AppConstants.apiApplications);
    final list = response is List ? response : (response['data'] ?? []);
    return list.map((e) => Application.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Application> getApplicationById(String id) async {
    final response = await _api.get('${AppConstants.apiApplications}/$id');
    return Application.fromJson(response as Map<String, dynamic>);
  }

  Future<Application> createApplication(Map<String, dynamic> data) async {
    final response = await _api.post(AppConstants.apiApplications, body: data);
    return Application.fromJson(response as Map<String, dynamic>);
  }

  Future<Application> updateApplicationStatus(String id, String status) async {
    final response = await _api.patch('${AppConstants.apiApplications}/$id', body: {'status': status});
    return Application.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteApplication(String id) async {
    await _api.delete('${AppConstants.apiApplications}/$id');
  }
}
