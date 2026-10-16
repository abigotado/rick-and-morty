import 'package:equatable/equatable.dart';
import 'package:rick_and_morty/features/characters/domain/character.dart';

class CharactersPage extends Equatable {
  const CharactersPage({required this.characters, this.nextPage});

  const CharactersPage.empty() : characters = const [], nextPage = null;

  final List<Character> characters;
  final int? nextPage;

  bool get hasMore => nextPage != null;

  @override
  List<Object?> get props => [characters, nextPage];
}
