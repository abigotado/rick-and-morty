import 'package:rick_and_morty_api/src/dto/dto.dart';
import 'package:rick_and_morty_api/src/exceptions/api_exception.dart';

/// Throws [ApiException] subtypes only.
abstract interface class ICharactersService {
  Future<CharactersPageDTO> getCharacters({required int page, String name = ''});

  Future<CharacterDTO> getCharacter(int id);
}
