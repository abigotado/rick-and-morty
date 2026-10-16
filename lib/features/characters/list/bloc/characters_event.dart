part of 'characters_bloc.dart';

sealed class CharactersEvent extends Equatable {
  const CharactersEvent();

  @override
  List<Object?> get props => [];
}

final class CharactersStarted extends CharactersEvent {
  const CharactersStarted();
}

final class CharactersQueryChanged extends CharactersEvent {
  const CharactersQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class CharactersNextPageRequested extends CharactersEvent {
  const CharactersNextPageRequested();
}

final class CharactersRetried extends CharactersEvent {
  const CharactersRetried();
}
