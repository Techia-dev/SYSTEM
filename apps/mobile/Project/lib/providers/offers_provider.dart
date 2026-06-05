import 'package:flutter/foundation.dart';
import '../data/models/offer_model.dart';
import '../data/repositories/offers_repository.dart';

enum OffersStatus { initial, loading, loaded, error }

class OffersProvider extends ChangeNotifier {
  final OffersRepository _repository;

  OffersStatus _status = OffersStatus.initial;
  List<Offer> _offers = [];
  String? _errorMessage;
  int _total = 0;
  int _currentPage = 1;
  int _totalPages = 1;

  OffersProvider({OffersRepository? repository})
      : _repository = repository ?? OffersRepository();

  OffersStatus get status => _status;
  List<Offer> get offers => _offers;
  String? get errorMessage => _errorMessage;
  int get total => _total;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoading => _status == OffersStatus.loading;
  bool get hasError => _status == OffersStatus.error;

  String get pageText => 'Page $_currentPage of $_totalPages';
  String get matchingText => '$_total offer${_total == 1 ? '' : 's'}';

  Future<void> loadOffers({int page = 1}) async {
    _status = OffersStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getOffers();
      _offers = response;
      _total = response.length;
      _currentPage = page;
      _totalPages = 1;
      _status = OffersStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('ApiException: ', '');
      _status = OffersStatus.error;
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == OffersStatus.error) {
      _status = OffersStatus.initial;
    }
    notifyListeners();
  }
}
