import '../client/api_client.dart';
import '../models/offer.dart';

class OffersRepository {
  final ApiClient _api;
  final String _basePath;

  OffersRepository({
    required ApiClient apiClient,
    String basePath = '/api/offers',
  })  : _api = apiClient,
        _basePath = basePath;

  Future<List<Offer>> list() async {
    final response = await _api.get(_basePath);
    final list = response is List ? response : (response['data'] ?? []);
    return List<Offer>.from(
      list.map((e) => Offer.fromJson(e as Map<String, dynamic>)),
    );
  }

  Future<Offer> getById(String id) async {
    final response = await _api.get('$_basePath/$id');
    return Offer.fromJson(response as Map<String, dynamic>);
  }

  Future<Offer> create(Map<String, dynamic> data) async {
    final response = await _api.post(_basePath, body: data);
    return Offer.fromJson(response as Map<String, dynamic>);
  }

  Future<Offer> update(String id, Map<String, dynamic> data) async {
    final response = await _api.put('$_basePath/$id', body: data);
    return Offer.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deactivate(String id) async {
    await _api.delete('$_basePath/$id');
  }
}
