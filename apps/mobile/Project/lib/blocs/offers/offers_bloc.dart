import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import '../../core/network.dart';

sealed class OffersEvent {}

final class OffersLoad extends OffersEvent {}

final class OffersCreate extends OffersEvent {
  final Map<String, dynamic> data;
  OffersCreate(this.data);
}

final class OffersDeactivate extends OffersEvent {
  final String id;
  OffersDeactivate(this.id);
}

final class OffersClearError extends OffersEvent {}

class OffersState {
  final List<Offer> items;
  final String? error;
  final bool isLoading;
  final int total;

  OffersState({
    this.items = const [],
    this.error,
    this.isLoading = false,
    this.total = 0,
  });

  OffersState copyWith({
    List<Offer>? items,
    String? error,
    bool? isLoading,
    int? total,
    bool clearError = false,
  }) {
    return OffersState(
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
      total: total ?? this.total,
    );
  }

  String get matchingText => '$total offer${total == 1 ? '' : 's'}';
}

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  final OffersRepository _repository;

  OffersBloc({OffersRepository? repository})
      : _repository = repository ?? OffersRepository(apiClient: apiClient),
        super(OffersState()) {
    on<OffersLoad>(_onLoad);
    on<OffersCreate>(_onCreate);
    on<OffersDeactivate>(_onDeactivate);
    on<OffersClearError>(_onClearError);
  }

  Future<void> _onLoad(OffersLoad event, Emitter<OffersState> emit) async {
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

  Future<void> _onCreate(OffersCreate event, Emitter<OffersState> emit) async {
    try {
      await _repository.create(event.data);
      add(OffersLoad());
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onDeactivate(OffersDeactivate event, Emitter<OffersState> emit) async {
    try {
      await _repository.deactivate(event.id);
      add(OffersLoad());
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  void _onClearError(OffersClearError event, Emitter<OffersState> emit) {
    emit(state.copyWith(clearError: true));
  }
}
