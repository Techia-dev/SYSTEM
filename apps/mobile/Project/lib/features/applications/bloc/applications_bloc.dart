import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import '../../../di/injection_container.dart';

sealed class ApplicationsEvent {}

final class ApplicationsLoad extends ApplicationsEvent {}

final class ApplicationsCreate extends ApplicationsEvent {
  final Map<String, dynamic> data;
  ApplicationsCreate(this.data);
}

final class ApplicationsUpdateStatus extends ApplicationsEvent {
  final String id;
  final String status;
  ApplicationsUpdateStatus(this.id, this.status);
}

final class ApplicationsDelete extends ApplicationsEvent {
  final String id;
  ApplicationsDelete(this.id);
}

final class ApplicationsClearError extends ApplicationsEvent {}

class ApplicationsState {
  final List<Application> items;
  final String? error;
  final bool isLoading;
  final int total;

  ApplicationsState({
    this.items = const [],
    this.error,
    this.isLoading = false,
    this.total = 0,
  });

  ApplicationsState copyWith({
    List<Application>? items,
    String? error,
    bool? isLoading,
    int? total,
    bool clearError = false,
  }) {
    return ApplicationsState(
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
      total: total ?? this.total,
    );
  }

  String get matchingText => '$total application${total == 1 ? '' : 's'}';
}

class ApplicationsBloc extends Bloc<ApplicationsEvent, ApplicationsState> {
  final ApplicationsRepository _repository;

  ApplicationsBloc({ApplicationsRepository? repository})
      : _repository = repository ?? sl<ApplicationsRepository>(),
        super(ApplicationsState()) {
    on<ApplicationsLoad>(_onLoad);
    on<ApplicationsCreate>(_onCreate);
    on<ApplicationsUpdateStatus>(_onUpdateStatus);
    on<ApplicationsDelete>(_onDelete);
    on<ApplicationsClearError>(_onClearError);
  }

  Future<void> _onLoad(ApplicationsLoad event, Emitter<ApplicationsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _repository.list();
      emit(state.copyWith(items: items, total: items.length, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString().replaceAll('ApiException: ', ''),
        isLoading: false,
      ));
    }
  }

  Future<void> _onCreate(ApplicationsCreate event, Emitter<ApplicationsState> emit) async {
    try {
      await _repository.create(event.data);
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
    add(ApplicationsLoad());
  }

  Future<void> _onUpdateStatus(ApplicationsUpdateStatus event, Emitter<ApplicationsState> emit) async {
    try {
      await _repository.updateStatus(event.id, event.status);
      add(ApplicationsLoad());
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onDelete(ApplicationsDelete event, Emitter<ApplicationsState> emit) async {
    try {
      await _repository.delete(event.id);
      add(ApplicationsLoad());
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  void _onClearError(ApplicationsClearError event, Emitter<ApplicationsState> emit) {
    emit(state.copyWith(clearError: true));
  }
}
