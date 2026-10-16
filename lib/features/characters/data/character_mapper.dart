import 'package:rick_and_morty/core/network/json_reader.dart';
import 'package:rick_and_morty/features/characters/domain/character.dart';
import 'package:rick_and_morty/features/characters/domain/characters_page.dart';

abstract final class CharacterMapper {
  static CharactersPage pageFromJson(Map<String, dynamic> json) {
    final next = json.read<Map<String, dynamic>>('info').read<String?>('next');
    return CharactersPage(
      characters: List.unmodifiable(json.readObjects('results').map(fromJson)),
      nextPage: next == null ? null : _pageNumber(next),
    );
  }

  static Character fromJson(Map<String, dynamic> json) {
    return Character(
      id: json.read<int>('id'),
      name: json.read<String>('name'),
      status: _status(json.read<String>('status')),
      species: json.read<String>('species'),
      type: json.read<String>('type'),
      gender: json.read<String>('gender'),
      origin: json.read<Map<String, dynamic>>('origin').read<String>('name'),
      location: json.read<Map<String, dynamic>>('location').read<String>('name'),
      imageUrl: json.read<String>('image'),
    );
  }

  static CharacterStatus _status(String value) => switch (value.toLowerCase()) {
    'alive' => CharacterStatus.alive,
    'dead' => CharacterStatus.dead,
    _ => CharacterStatus.unknown,
  };

  static int _pageNumber(String url) {
    final page = int.tryParse(Uri.parse(url).queryParameters['page'] ?? '');
    if (page == null) throw FormatException('No page number in "$url"');
    return page;
  }
}
