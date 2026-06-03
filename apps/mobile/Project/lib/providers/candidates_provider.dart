import 'package:flutter/foundation.dart';
import '../data/models/candidate_model.dart';
import '../data/models/candidate_filter_model.dart';
import '../data/repositories/candidates_repository.dart';

enum CandidatesStatus { initial, loading, loaded, refreshing, error }

class CandidatesProvider extends ChangeNotifier {
  final CandidatesRepository _repository;

  CandidatesStatus _status = CandidatesStatus.initial;
  List<Candidate> _candidates = [];
  Candidate? _selectedCandidate;
  String? _errorMessage;
  DateTime? _lastSynced;

  CandidateFilter _filter = const CandidateFilter();
  int _total = 0;
  int _currentPage = 1;
  int _totalPages = 1;

  // Stats
  int _totalCount = 0;
  int _appliedCount = 0;
  int _interviewCount = 0;
  int _hiredCount = 0;

  CandidatesProvider({CandidatesRepository? repository})
      : _repository = repository ?? CandidatesRepository();

  // Getters
  CandidatesStatus get status => _status;
  List<Candidate> get candidates => _candidates;
  Candidate? get selectedCandidate => _selectedCandidate;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSynced => _lastSynced;
  CandidateFilter get filter => _filter;
  int get total => _total;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoading => _status == CandidatesStatus.loading;
  bool get isRefreshing => _status == CandidatesStatus.refreshing;
  bool get hasError => _status == CandidatesStatus.error;

  int get totalCount => _totalCount;
  int get appliedCount => _appliedCount;
  int get interviewCount => _interviewCount;
  int get hiredCount => _hiredCount;

  String get matchingText =>
      '$_total matching candidate${_total == 1 ? '' : 's'}';

  String get pageText => 'Page $_currentPage of $_totalPages';
  String get pageCountText => '$_currentPage/$_totalPages';

  Future<void> loadCandidates({bool refresh = false}) async {
    if (refresh) {
      _status = CandidatesStatus.refreshing;
    } else {
      _status = CandidatesStatus.loading;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getCandidates(_filter);
      _candidates = result.candidates as List<Candidate>;
      _total = result.total;
      _currentPage = result.page;
      _totalPages = result.totalPages;
      _lastSynced = DateTime.now();

      // Also load all for stats
      final allResult = await _repository.getCandidates(
        const CandidateFilter(pageSize: 1000),
      );
      final allCandidates = allResult.candidates as List<Candidate>;
      final stats = _repository.getCandidateStats(allCandidates);
      _totalCount = stats['total'] ?? 0;
      _appliedCount = stats['applied'] ?? 0;
      _interviewCount = stats['interview'] ?? 0;
      _hiredCount = stats['hired'] ?? 0;

      _status = CandidatesStatus.loaded;

      if (_candidates.isNotEmpty && _selectedCandidate == null) {
        _selectedCandidate = _candidates.first;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('ApiException: ', '');
      _status = CandidatesStatus.error;
    }
    notifyListeners();
  }

  void selectCandidate(Candidate candidate) {
    _selectedCandidate = candidate;
    notifyListeners();
  }

  Future<void> advanceToInterview(String candidateId) async {
    try {
      final updated = await _repository.advanceCandidateStage(candidateId);
      final index = _candidates.indexWhere((c) => c.id == candidateId);
      if (index != -1) {
        _candidates[index] = updated;
      }
      if (_selectedCandidate?.id == candidateId) {
        _selectedCandidate = updated;
      }
      notifyListeners();
      await loadCandidates(refresh: true);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('ApiException: ', '');
      notifyListeners();
    }
  }

  void updateFilter({
    String? searchQuery,
    String? status,
    String? level,
    int? page,
  }) {
    _filter = _filter.copyWith(
      searchQuery: searchQuery,
      status: status,
      level: level,
      page: page ?? 1,
    );
    loadCandidates();
  }

  void goToPage(int page) {
    if (page < 1 || page > _totalPages) return;
    _filter = _filter.copyWith(page: page);
    _currentPage = page;
    loadCandidates();
  }

  void nextPage() => goToPage(_currentPage + 1);
  void previousPage() => goToPage(_currentPage - 1);

  Future<void> refreshSelectedCandidate() async {
    if (_selectedCandidate == null) return;
    try {
      final updated = await _repository.getCandidateById(_selectedCandidate!.id);
      _selectedCandidate = updated;
      notifyListeners();
    } catch (_) {}
  }

  void clearError() {
    _errorMessage = null;
    if (_status == CandidatesStatus.error) {
      _status = CandidatesStatus.initial;
    }
    notifyListeners();
  }
}
