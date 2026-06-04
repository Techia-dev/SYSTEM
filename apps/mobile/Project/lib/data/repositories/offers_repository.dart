import '../services/api_service.dart';
import '../models/offer_model.dart';
import '../../core/constants/app_constants.dart';

class OffersRepository {
  final ApiService _api;

  OffersRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

  Future<List<Offer>> getOffers() async {
    final response = await _api.get(AppConstants.apiOffers);
    final list = response is List ? response : (response['data'] ?? []);
    return list.map((e) => Offer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Offer> getOfferById(String id) async {
    final response = await _api.get('${AppConstants.apiOffers}/$id');
    return Offer.fromJson(response as Map<String, dynamic>);
  }

  Future<Offer> createOffer(Map<String, dynamic> data) async {
    final response = await _api.post(AppConstants.apiOffers, body: data);
    return Offer.fromJson(response as Map<String, dynamic>);
  }

  Future<Offer> updateOffer(String id, Map<String, dynamic> data) async {
    final response = await _api.put('${AppConstants.apiOffers}/$id', body: data);
    return Offer.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deactivateOffer(String id) async {
    await _api.delete('${AppConstants.apiOffers}/$id');
  }
}
