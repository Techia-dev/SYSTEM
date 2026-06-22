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

final class CandidatesUpdateFilter extends CandidatesEvent {
  final String? searchQuery;
  final String? status;
  final String? level;
  final int? page;
  CandidatesUpdateFilter({this.searchQuery, this.status, this.level, this.page});
}

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

final class CandidatesUploadCv extends CandidatesEvent {
  final String id;
  final String filePath;
  CandidatesUploadCv(this.id, this.filePath);
}

final class CandidatesClearError extends CandidatesEvent {}

class CandidatesState {
  final List<Candidate> items;
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
  final int rejectedCount;

  CandidatesState({
    this.items = const [],
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
    this.rejectedCount = 0,
  });

  CandidatesState copyWith({
    List<Candidate>? items,
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
    int? rejectedCount,
    bool clearError = false,
  }) {
    return CandidatesState(
      items: items ?? this.items,
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
      rejectedCount: rejectedCount ?? this.rejectedCount,
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
    on<CandidatesUpdateFilter>(_onUpdateFilter);
    on<CandidatesCreate>(_onCreate);
    on<CandidatesUpdate>(_onUpdate);
    on<CandidatesDelete>(_onDelete);
    on<CandidatesUploadCv>(_onUploadCv);
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
        totalCount: all.length,
        appliedCount: all.where((c) => c.status == AppConstants.stageApplied).length,
        interviewCount: all.where((c) => c.status == AppConstants.stageInterview).length,
        hiredCount: all.where((c) => c.status == AppConstants.stageHired || c.status == 'accepted').length,
        rejectedCount: all.where((c) => c.status == 'rejected').length,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString().replaceAll('ApiException: ', ''),
        isLoading: false,
        isRefreshing: false,
      ));
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
      emit(state.copyWith(items: items));
      add(CandidatesLoad(refresh: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onDelete(CandidatesDelete event, Emitter<CandidatesState> emit) async {
    try {
      await _repository.delete(event.id);
      add(CandidatesLoad());
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onUploadCv(CandidatesUploadCv event, Emitter<CandidatesState> emit) async {
    try {
      final updated = await _repository.uploadCv(event.id, event.filePath);
      final items = state.items.map((c) => c.id == event.id ? updated : c).toList();
      emit(state.copyWith(items: items));
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  void _onClearError(CandidatesClearError event, Emitter<CandidatesState> emit) {
    emit(state.copyWith(clearError: true));
  }
}
