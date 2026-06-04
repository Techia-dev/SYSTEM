import '../services/api_service.dart';
import '../models/commission_model.dart';
import '../../core/constants/app_constants.dart';

class CommissionsRepository {
  final ApiService _api;

  CommissionsRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

  Future<List<Commission>> getCommissions() async {
    final response = await _api.get(AppConstants.apiCommissions);
    final list = response is List ? response : (response['data'] ?? []);
    return list.map((e) => Commission.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Commission> getCommissionById(String id) async {
    final response = await _api.get('${AppConstants.apiCommissions}/$id');
    return Commission.fromJson(response as Map<String, dynamic>);
  }

  Future<Commission> updateCommissionStatus(String id, String status) async {
    final response = await _api.patch('${AppConstants.apiCommissions}/$id', body: {'status': status});
    return Commission.fromJson(response as Map<String, dynamic>);
  }
}
