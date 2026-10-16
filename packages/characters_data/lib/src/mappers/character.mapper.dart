import 'package:characters_domain/characters_domain.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';

abstract final class CharacterMapper {
  static CharacterEntity toEntity(CharacterDTO dto) => CharacterEntity(
    id: dto.id,
    name: dto.name,
    status: switch (dto.status.toLowerCase()) {
      'alive' => CharacterStatus.alive,
      'dead' => CharacterStatus.dead,
      _ => CharacterStatus.unknown,
    },
    species: dto.species,
    type: dto.type,
    gender: dto.gender,
    origin: dto.origin.name,
    location: dto.location.name,
    imageUrl: _secureUrl(dto.image),
  );

  static CharactersPageEntity toPageEntity(CharactersPageDTO dto) => CharactersPageEntity(
    characters: List.unmodifiable(dto.results.map(toEntity)),
    totalCount: dto.info.count,
    nextPage: switch (dto.info.next) {
      final url? => _pageNumber(url),
      null => null,
    },
  );

  static const _imageHost = 'rickandmortyapi.com';

  static Uri? _secureUrl(String value) => switch (Uri.tryParse(value)) {
    final uri? when uri.isScheme('https') && uri.host == _imageHost && uri.userInfo.isEmpty => uri,
    _ => null,
  };

  static int _pageNumber(String url) {
    final page = int.tryParse(Uri.parse(url).queryParameters['page'] ?? '');
    if (page == null) throw FormatException('No page number in "$url"');
    return page;
  }
}
