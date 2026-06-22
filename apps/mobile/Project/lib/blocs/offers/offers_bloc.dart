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

final class OffersUpdateFilter extends OffersEvent {
  final String? searchQuery;
  final bool? showInactive;
  OffersUpdateFilter({this.searchQuery, this.showInactive});
}

final class OffersClearError extends OffersEvent {}

class OffersState {
  final List<Offer> items;
  final List<Offer> filteredItems;
  final String? error;
  final bool isLoading;
  final int total;
  final String searchQuery;
  final bool showInactive;

  OffersState({
    this.items = const [],
    this.filteredItems = const [],
    this.error,
    this.isLoading = false,
    this.total = 0,
    this.searchQuery = '',
    this.showInactive = false,
  });

  OffersState copyWith({
    List<Offer>? items,
    List<Offer>? filteredItems,
    String? error,
    bool? isLoading,
    int? total,
    String? searchQuery,
    bool? showInactive,
    bool clearError = false,
  }) {
    return OffersState(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
      showInactive: showInactive ?? this.showInactive,
    );
  }

  String get matchingText => '${filteredItems.length} offer${filteredItems.length == 1 ? '' : 's'}';
}

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  final OffersRepository _repository;

  OffersBloc({OffersRepository? repository})
      : _repository = repository ?? OffersRepository(apiClient: apiClient),
        super(OffersState()) {
    on<OffersLoad>(_onLoad);
    on<OffersCreate>(_onCreate);
    on<OffersDeactivate>(_onDeactivate);
    on<OffersUpdateFilter>(_onUpdateFilter);
    on<OffersClearError>(_onClearError);
  }

  List<Offer> _applyFilter(List<Offer> items, String searchQuery, bool showInactive) {
    var result = items;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((o) =>
        o.title.toLowerCase().contains(q) ||
        (o.company?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    if (!showInactive) {
      result = result.where((o) => o.isActive).toList();
    }
    return result;
  }

  Future<void> _onLoad(OffersLoad event, Emitter<OffersState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _repository.list();
      final filtered = _applyFilter(items, state.searchQuery, state.showInactive);
      emit(state.copyWith(
        items: items,
        filteredItems: filtered,
        total: items.length,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString().replaceAll('ApiException: ', ''),
        isLoading: false,
      ));
    }
  }

  void _onUpdateFilter(OffersUpdateFilter event, Emitter<OffersState> emit) {
    final query = event.searchQuery ?? state.searchQuery;
    final inactive = event.showInactive ?? state.showInactive;
    final filtered = _applyFilter(state.items, query, inactive);
    emit(state.copyWith(
      filteredItems: filtered,
      searchQuery: query,
      showInactive: inactive,
    ));
  }

  Future<void> _onCreate(OffersCreate event, Emitter<OffersState> emit) async {
    try {
      await _repository.create(event.data);
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
    add(OffersLoad());
  }

  Future<void> _onDeactivate(OffersDeactivate event, Emitter<OffersState> emit) async {
    try {
      await _repository.deactivate(event.id);
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('ApiException: ', '')));
    }
    add(OffersLoad());
  }

  void _onClearError(OffersClearError event, Emitter<OffersState> emit) {
    emit(state.copyWith(clearError: true));
  }
}
