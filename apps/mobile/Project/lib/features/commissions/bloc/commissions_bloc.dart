import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import '../../../di/injection_container.dart';

sealed class CommissionsEvent {}

final class CommissionsLoad extends CommissionsEvent {}

final class CommissionsUpdateStatus extends CommissionsEvent {
  final String id;
  final String status;
  CommissionsUpdateStatus(this.id, this.status);
}

final class CommissionsClearError extends CommissionsEvent {}

class CommissionsState {
  final List<Commission> items;
  final String? error;
  final bool isLoading;
  final int total;

  CommissionsState({
    this.items = const [],
    this.error,
    this.isLoading = false,
    this.total = 0,
  });

  CommissionsState copyWith({
    List<Commission>? items,
    String? error,
    bool? isLoading,
    int? total,
    bool clearError = false,
  }) {
    return CommissionsState(
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
      total: total ?? this.total,
    );
  }

  String get matchingText => '$total commission${total == 1 ? '' : 's'}';
}

class CommissionsBloc extends Bloc<CommissionsEvent, CommissionsState> {
  final CommissionsRepository _repository;

  CommissionsBloc({CommissionsRepository? repository})
      : _repository = repository ?? sl<CommissionsRepository>(),
        super(CommissionsState()) {
    on<CommissionsLoad>(_onLoad);
    on<CommissionsUpdateStatus>(_onUpdateStatus);
    on<CommissionsClearError>(_onClearError);
  }

  Future<void> _onLoad(CommissionsLoad event, Emitter<CommissionsState> emit) async {
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

  Future<void> _onUpdateStatus(CommissionsUpdateStatus event, Emitter<CommissionsState> emit) async {
    try {
      await _repository.updateStatus(event.id, event.status);
      add(CommissionsLoad());
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  void _onClearError(CommissionsClearError event, Emitter<CommissionsState> emit) {
    emit(state.copyWith(clearError: true));
  }
}
