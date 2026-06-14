import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import '../../core/network.dart';
import '../../core/constants/app_constants.dart';

sealed class CandidatesEvent {}

final class CandidatesLoad extends CandidatesEvent {
  final bool refresh;
  CandidatesLoad({this.refresh = false});
}

final class CandidatesSelect extends CandidatesEvent {
  final Candidate candidate;
  CandidatesSelect(this.candidate);
}

final class CandidatesAdvanceStage extends CandidatesEvent {
  final String candidateId;
  CandidatesAdvanceStage(this.candidateId);
}

final class CandidatesUpdateFilter extends CandidatesEvent {
  final String? searchQuery;
  final String? status;
  final String? level;
  final int? page;
  CandidatesUpdateFilter({this.searchQuery, this.status, this.level, this.page});
}

final class CandidatesGoToPage extends CandidatesEvent {
  final int page;
  CandidatesGoToPage(this.page);
}

final class CandidatesNextPage extends CandidatesEvent {}

final class CandidatesPreviousPage extends CandidatesEvent {}

final class CandidatesRefreshSelected extends CandidatesEvent {}

final class CandidatesCreate extends CandidatesEvent {
  final Map<String, dynamic> data;
  CandidatesCreate(this.data);
}

final class CandidatesUpdate extends CandidatesEvent {
  final String id;
  final Map<String, dynamic> data;
  CandidatesUpdate(this.id, this.data);
}

final class CandidatesDelete extends CandidatesEvent {
  final String id;
  CandidatesDelete(this.id);
}

final class CandidatesClearError extends CandidatesEvent {}

class CandidatesState {
  final List<Candidate> items;
  final Candidate? selected;
  final String? error;
  final bool isLoading;
  final bool isRefreshing;
  final int total;
  final int currentPage;
  final int totalPages;
  final ListFilter filter;
  final DateTime? lastSynced;
  final int totalCount;
  final int appliedCount;
  final int interviewCount;
  final int hiredCount;

  CandidatesState({
    this.items = const [],
    this.selected,
    this.error,
    this.isLoading = false,
    this.isRefreshing = false,
    this.total = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.filter = const ListFilter(),
    this.lastSynced,
    this.totalCount = 0,
    this.appliedCount = 0,
    this.interviewCount = 0,
    this.hiredCount = 0,
  });

  CandidatesState copyWith({
    List<Candidate>? items,
    Candidate? selected,
    String? error,
    bool? isLoading,
    bool? isRefreshing,
    int? total,
    int? currentPage,
    int? totalPages,
    ListFilter? filter,
    DateTime? lastSynced,
    int? totalCount,
    int? appliedCount,
    int? interviewCount,
    int? hiredCount,
    bool clearError = false,
  }) {
    return CandidatesState(
      items: items ?? this.items,
      selected: selected ?? this.selected,
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      filter: filter ?? this.filter,
      lastSynced: lastSynced ?? this.lastSynced,
      totalCount: totalCount ?? this.totalCount,
      appliedCount: appliedCount ?? this.appliedCount,
      interviewCount: interviewCount ?? this.interviewCount,
      hiredCount: hiredCount ?? this.hiredCount,
    );
  }

  String get matchingText => '$total matching candidate${total == 1 ? '' : 's'}';
  String get pageText => 'Page $currentPage of $totalPages';
  String get pageCountText => '$currentPage/$totalPages';
}

class CandidatesBloc extends Bloc<CandidatesEvent, CandidatesState> {
  final CandidatesRepository _repository;

  CandidatesBloc({CandidatesRepository? repository})
      : _repository = repository ?? CandidatesRepository(apiClient: apiClient),
        super(CandidatesState()) {
    on<CandidatesLoad>(_onLoad);
    on<CandidatesSelect>(_onSelect);
    on<CandidatesAdvanceStage>(_onAdvanceStage);
    on<CandidatesUpdateFilter>(_onUpdateFilter);
    on<CandidatesGoToPage>(_onGoToPage);
    on<CandidatesNextPage>(_onNextPage);
    on<CandidatesPreviousPage>(_onPreviousPage);
    on<CandidatesRefreshSelected>(_onRefreshSelected);
    on<CandidatesCreate>(_onCreate);
    on<CandidatesUpdate>(_onUpdate);
    on<CandidatesDelete>(_onDelete);
    on<CandidatesClearError>(_onClearError);
  }

  Future<void> _onLoad(CandidatesLoad event, Emitter<CandidatesState> emit) async {
    emit(state.copyWith(
      isLoading: !event.refresh,
      isRefreshing: event.refresh,
      error: null,
    ));
    try {
      final result = await _repository.list(filter: state.filter);
      final allResult = await _repository.list(
        filter: const ListFilter(pageSize: 1000),
      );
      final all = allResult.items;
      emit(state.copyWith(
        items: result.items,
        total: result.total,
        currentPage: result.page,
        totalPages: result.totalPages,
        lastSynced: DateTime.now(),
        isLoading: false,
        isRefreshing: false,
        selected: result.items.isNotEmpty && state.selected == null ? result.items.first : state.selected,
        totalCount: all.length,
        appliedCount: all.where((c) => c.status == AppConstants.stageApplied).length,
        interviewCount: all.where((c) => c.status == AppConstants.stageInterview).length,
        hiredCount: all.where((c) => c.status == AppConstants.stageHired).length,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString().replaceAll('ApiException: ', ''),
        isLoading: false,
        isRefreshing: false,
      ));
    }
  }

  void _onSelect(CandidatesSelect event, Emitter<CandidatesState> emit) {
    emit(state.copyWith(selected: event.candidate));
  }

  Future<void> _onAdvanceStage(CandidatesAdvanceStage event, Emitter<CandidatesState> emit) async {
    try {
      final updated = await _repository.advanceStage(event.candidateId);
      final items = state.items.map((c) => c.id == event.candidateId ? updated : c).toList();
      emit(state.copyWith(
        items: items,
        selected: state.selected?.id == event.candidateId ? updated : state.selected,
      ));
      add(CandidatesLoad(refresh: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  void _onUpdateFilter(CandidatesUpdateFilter event, Emitter<CandidatesState> emit) {
    final f = state.filter.copyWith(
      searchQuery: event.searchQuery,
      status: event.status,
      level: event.level,
      page: event.page ?? 1,
    );
    emit(state.copyWith(filter: f));
    add(CandidatesLoad());
  }

  void _onGoToPage(CandidatesGoToPage event, Emitter<CandidatesState> emit) {
    if (event.page < 1 || event.page > state.totalPages) return;
    final f = state.filter.copyWith(page: event.page);
    emit(state.copyWith(filter: f, currentPage: event.page));
    add(CandidatesLoad());
  }

  void _onNextPage(CandidatesNextPage event, Emitter<CandidatesState> emit) {
    add(CandidatesGoToPage(state.currentPage + 1));
  }

  void _onPreviousPage(CandidatesPreviousPage event, Emitter<CandidatesState> emit) {
    add(CandidatesGoToPage(state.currentPage - 1));
  }

  Future<void> _onCreate(CandidatesCreate event, Emitter<CandidatesState> emit) async {
    try {
      await _repository.create(event.data);
      add(CandidatesLoad());
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onUpdate(CandidatesUpdate event, Emitter<CandidatesState> emit) async {
    try {
      final updated = await _repository.update(event.id, event.data);
      final items = state.items.map((c) => c.id == event.id ? updated : c).toList();
      emit(state.copyWith(
        items: items,
        selected: state.selected?.id == event.id ? updated : state.selected,
      ));
      add(CandidatesLoad(refresh: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onDelete(CandidatesDelete event, Emitter<CandidatesState> emit) async {
    try {
      await _repository.delete(event.id);
      emit(state.copyWith(
        selected: state.selected?.id == event.id ? null : state.selected,
      ));
      add(CandidatesLoad());
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onRefreshSelected(CandidatesRefreshSelected event, Emitter<CandidatesState> emit) async {
    if (state.selected == null) return;
    try {
      final updated = await _repository.getById(state.selected!.id);
      emit(state.copyWith(selected: updated));
    } catch (_) {}
  }

  void _onClearError(CandidatesClearError event, Emitter<CandidatesState> emit) {
    emit(state.copyWith(clearError: true));
  }
}
