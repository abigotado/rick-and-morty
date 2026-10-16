import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/core/failure.dart';
import 'package:rick_and_morty/features/characters/domain/character.dart';
import 'package:rick_and_morty/features/characters/domain/characters_repository.dart';

part 'characters_event.dart';
part 'characters_state.dart';

class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {
  CharactersBloc(this._repository) : super(const CharactersState()) {
    on<CharactersStarted>(_onStarted, transformer: droppable());
    on<CharactersNextPageRequested>(_onNextPageRequested, transformer: droppable());
    on<CharactersRetried>(_onRetried, transformer: droppable());
  }

  final CharactersRepository _repository;

  Future<void> _onStarted(CharactersStarted event, Emitter<CharactersState> emit) {
    return _loadFirstPage(state.query, emit);
  }

  Future<void> _onNextPageRequested(
    CharactersNextPageRequested event,
    Emitter<CharactersState> emit,
  ) async {
    if (state.status != CharactersStatus.success) return;
    if (state.nextPageStatus != NextPageStatus.idle) return;
    if (state.nextPage case final page?) await _loadNextPage(page, emit);
  }

  Future<void> _onRetried(CharactersRetried event, Emitter<CharactersState> emit) async {
    if (state.status == CharactersStatus.failure) return _loadFirstPage(state.query, emit);
    if (state.nextPageStatus != NextPageStatus.failure) return;
    if (state.nextPage case final page?) await _loadNextPage(page, emit);
  }

  Future<void> _loadFirstPage(String query, Emitter<CharactersState> emit) async {
    emit(CharactersState(status: CharactersStatus.loading, query: query));
    try {
      final page = await _repository.getCharacters(name: query);
      if (state.query != query) return;
      emit(
        CharactersState(
          status: CharactersStatus.success,
          characters: page.characters,
          query: query,
          nextPage: page.nextPage,
        ),
      );
    } on Failure catch (failure) {
      if (state.query != query) return;
      emit(CharactersState(status: CharactersStatus.failure, query: query, failure: failure));
    }
  }

  Future<void> _loadNextPage(int page, Emitter<CharactersState> emit) async {
    final query = state.query;
    emit(state.copyWith(nextPageStatus: NextPageStatus.loading));
    try {
      final result = await _repository.getCharacters(page: page, name: query);
      if (state.query != query || state.nextPage != page) return;
      emit(
        state.copyWith(
          characters: List.unmodifiable([...state.characters, ...result.characters]),
          nextPage: () => result.nextPage,
          nextPageStatus: NextPageStatus.idle,
        ),
      );
    } on Failure {
      if (state.query != query || state.nextPage != page) return;
      emit(state.copyWith(nextPageStatus: NextPageStatus.failure));
    }
  }
}
