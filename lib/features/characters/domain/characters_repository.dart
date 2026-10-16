import 'package:rick_and_morty/features/characters/domain/character.dart';
import 'package:rick_and_morty/features/characters/domain/characters_page.dart';

abstract interface class CharactersRepository {
  /// A search with no matches yields an empty page, not a failure.
  Future<CharactersPage> getCharacters({int page = 1, String name = ''});

  Future<Character> getCharacter(int id);
}
