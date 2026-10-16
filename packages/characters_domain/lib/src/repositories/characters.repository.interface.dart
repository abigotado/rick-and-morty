import 'package:characters_domain/src/entities/character.entity.dart';
import 'package:characters_domain/src/entities/characters_page.entity.dart';
import 'package:characters_domain/src/failures/failure.dart';

/// Throws [Failure] subtypes only.
abstract interface class ICharactersRepository {
  /// A search with no matches yields an empty page, not a failure.
  Future<CharactersPageEntity> getCharacters({int page = 1, String name = ''});

  Future<CharacterEntity> getCharacter(int id);
}
