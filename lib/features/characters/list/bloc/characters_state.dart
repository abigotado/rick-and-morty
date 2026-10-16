part of 'characters_bloc.dart';

enum CharactersStatus { initial, loading, success, failure }

enum NextPageStatus { idle, loading, failure }

final class CharactersState extends Equatable {
  const CharactersState({
    this.status = CharactersStatus.initial,
    this.characters = const [],
    this.query = '',
    this.totalCount = 0,
    this.nextPage,
    this.nextPageStatus = NextPageStatus.idle,
    this.failure,
  });

  final CharactersStatus status;
  final List<CharacterEntity> characters;
  final String query;
  final int totalCount;
  final int? nextPage;
  final NextPageStatus nextPageStatus;
  final Failure? failure;

  bool get hasMore => nextPage != null;

  bool get canLoadMore =>
      status == CharactersStatus.success && hasMore && nextPageStatus == NextPageStatus.idle;

  CharactersState copyWith({
    List<CharacterEntity>? characters,
    int? Function()? nextPage,
    NextPageStatus? nextPageStatus,
  }) {
    return CharactersState(
      status: status,
      characters: characters ?? this.characters,
      query: query,
      totalCount: totalCount,
      nextPage: nextPage != null ? nextPage() : this.nextPage,
      nextPageStatus: nextPageStatus ?? this.nextPageStatus,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    characters,
    query,
    totalCount,
    nextPage,
    nextPageStatus,
    failure,
  ];
}
