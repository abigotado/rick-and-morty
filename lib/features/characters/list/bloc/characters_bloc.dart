import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:characters_domain/characters_domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/core/bloc/debounce_restartable.dart';

part 'characters_event.dart';
part 'characters_state.dart';

class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {
  CharactersBloc({
    required ICharactersRepository charactersRepository,
    Duration searchDebounce = const Duration(milliseconds: 400),
  }) : _repository = charactersRepository,
       super(const CharactersState()) {
    on<CharactersStarted>(_onStarted, transformer: droppable());
    on<CharactersQueryChanged>(_onQueryChanged, transformer: debounceRestartable(searchDebounce));
    // Not droppable: a stale load from a previous query would swallow the next request.
    // The handlers emit a loading status before their first await, so the state guards
    // already keep page loads single-flight.
    on<CharactersNextPageRequested>(_onNextPageRequested);
    on<CharactersRetried>(_onRetried);
  }

  final ICharactersRepository _repository;

  // Bumped by every first-page load, so a response from a superseded load (even one for the
  // same query) is dropped instead of overwriting newer state.
  int _loadToken = 0;

  Future<void> _onStarted(CharactersStarted event, Emitter<CharactersState> emit) {
    return _loadFirstPage(state.query, emit);
  }

  Future<void> _onQueryChanged(CharactersQueryChanged event, Emitter<CharactersState> emit) async {
    final query = event.query.trim();
    if (query == state.query && state.status == CharactersStatus.success) return;
    await _loadFirstPage(query, emit);
  }

  Future<void> _onNextPageRequested(
    CharactersNextPageRequested event,
    Emitter<CharactersState> emit,
  ) async {
    if (!state.canLoadMore) return;
    if (state.nextPage case final page?) await _loadNextPage(page, emit);
  }

  Future<void> _onRetried(CharactersRetried event, Emitter<CharactersState> emit) async {
    if (state.status == CharactersStatus.failure) return _loadFirstPage(state.query, emit);
    if (state.nextPageStatus != NextPageStatus.failure) return;
    if (state.nextPage case final page?) await _loadNextPage(page, emit);
  }

  Future<void> _loadFirstPage(String query, Emitter<CharactersState> emit) async {
    final token = ++_loadToken;
    emit(CharactersState(status: CharactersStatus.loading, query: query));
    try {
      final page = await _repository.getCharacters(name: query);
      if (token != _loadToken) return;
      emit(
        CharactersState(
          status: CharactersStatus.success,
          characters: page.characters,
          query: query,
          totalCount: page.totalCount,
          nextPage: page.nextPage,
        ),
      );
    } on Failure catch (failure) {
      if (token != _loadToken) return;
      emit(CharactersState(status: CharactersStatus.failure, query: query, failure: failure));
    }
  }

  Future<void> _loadNextPage(int page, Emitter<CharactersState> emit) async {
    final token = _loadToken;
    emit(state.copyWith(nextPageStatus: NextPageStatus.loading));
    try {
      final result = await _repository.getCharacters(page: page, name: state.query);
      if (token != _loadToken) return;
      emit(
        state.copyWith(
          characters: List.unmodifiable([...state.characters, ...result.characters]),
          nextPage: () => result.nextPage,
          nextPageStatus: NextPageStatus.idle,
        ),
      );
    } on Failure {
      if (token != _loadToken) return;
      emit(state.copyWith(nextPageStatus: NextPageStatus.failure));
    }
  }
}
