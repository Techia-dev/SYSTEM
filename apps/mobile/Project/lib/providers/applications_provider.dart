import 'package:flutter/foundation.dart';
import '../data/models/application_model.dart';
import '../data/repositories/applications_repository.dart';

enum ApplicationsStatus { initial, loading, loaded, error }

class ApplicationsProvider extends ChangeNotifier {
  final ApplicationsRepository _repository;

  ApplicationsStatus _status = ApplicationsStatus.initial;
  List<Application> _applications = [];
  String? _errorMessage;
  int _total = 0;
  int _currentPage = 1;
  int _totalPages = 1;

  ApplicationsProvider({ApplicationsRepository? repository})
      : _repository = repository ?? ApplicationsRepository();

  ApplicationsStatus get status => _status;
  List<Application> get applications => _applications;
  String? get errorMessage => _errorMessage;
  int get total => _total;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoading => _status == ApplicationsStatus.loading;
  bool get hasError => _status == ApplicationsStatus.error;

  String get pageText => 'Page $_currentPage of $_totalPages';
  String get matchingText => '$_total application${_total == 1 ? '' : 's'}';

  Future<void> loadApplications({int page = 1}) async {
    _status = ApplicationsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getApplications();
      _applications = response;
      _total = response.length;
      _currentPage = page;
      _totalPages = 1;
      _status = ApplicationsStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('ApiException: ', '');
      _status = ApplicationsStatus.error;
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == ApplicationsStatus.error) {
      _status = ApplicationsStatus.initial;
    }
    notifyListeners();
  }
}
