import 'package:flutter/foundation.dart';
import '../data/models/commission_model.dart';
import '../data/repositories/commissions_repository.dart';

enum CommissionsStatus { initial, loading, loaded, error }

class CommissionsProvider extends ChangeNotifier {
  final CommissionsRepository _repository;

  CommissionsStatus _status = CommissionsStatus.initial;
  List<Commission> _commissions = [];
  String? _errorMessage;
  int _total = 0;
  int _currentPage = 1;
  int _totalPages = 1;

  CommissionsProvider({CommissionsRepository? repository})
      : _repository = repository ?? CommissionsRepository();

  CommissionsStatus get status => _status;
  List<Commission> get commissions => _commissions;
  String? get errorMessage => _errorMessage;
  int get total => _total;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoading => _status == CommissionsStatus.loading;
  bool get hasError => _status == CommissionsStatus.error;

  String get pageText => 'Page $_currentPage of $_totalPages';
  String get matchingText => '$_total commission${_total == 1 ? '' : 's'}';

  Future<void> loadCommissions({int page = 1}) async {
    _status = CommissionsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getCommissions();
      _commissions = response;
      _total = response.length;
      _currentPage = page;
      _totalPages = 1;
      _status = CommissionsStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('ApiException: ', '');
      _status = CommissionsStatus.error;
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == CommissionsStatus.error) {
      _status = CommissionsStatus.initial;
    }
    notifyListeners();
  }
}
