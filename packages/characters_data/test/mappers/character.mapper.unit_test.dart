import 'package:characters_data/src/mappers/character.mapper.dart';
import 'package:characters_domain/characters_domain.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';
import 'package:test/test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('CharacterMapper', () {
    group('toEntity', () {
      test('full dto → maps every field', () {
        expect(CharacterMapper.toEntity(characterDto()), rick);
      });

      test('non-empty type → kept', () {
        final character = CharacterMapper.toEntity(characterDto(type: 'Genetic experiment'));

        expect(character.type, 'Genetic experiment');
      });

      const statuses = {
        'Alive': CharacterStatus.alive,
        'alive': CharacterStatus.alive,
        'ALIVE': CharacterStatus.alive,
        'Dead': CharacterStatus.dead,
        'dead': CharacterStatus.dead,
        'unknown': CharacterStatus.unknown,
        'Unknown': CharacterStatus.unknown,
        'zombie': CharacterStatus.unknown,
        '': CharacterStatus.unknown,
      };
      for (final MapEntry(key: raw, value: status) in statuses.entries) {
        test('status "$raw" → ${status.name}', () {
          expect(CharacterMapper.toEntity(characterDto(status: raw)).status, status);
        });
      }

      test('unknown origin and location with empty url → names kept', () {
        final character = CharacterMapper.toEntity(
          characterDto(
            origin: const LocationRefDTO(name: 'unknown', url: ''),
            location: const LocationRefDTO(name: 'Earth (Replacement Dimension)', url: ''),
          ),
        );

        expect(character.origin, 'unknown');
        expect(character.location, 'Earth (Replacement Dimension)');
      });

      test('https image on the api host → imageUrl is that uri', () {
        const image = 'https://rickandmortyapi.com/api/character/avatar/2.jpeg';

        final character = CharacterMapper.toEntity(characterDto(image: image));

        expect(character.imageUrl, Uri.parse(image));
      });

      for (final image in [
        'http://rickandmortyapi.com/api/character/avatar/1.jpeg',
        '',
        'not a url',
        'https://',
        'javascript:alert(1)',
        'file:///etc/passwd',
        'https:rickandmortyapi.com/avatar.jpeg',
        ' https://rickandmortyapi.com/api/character/avatar/1.jpeg',
        'https://evil.example/avatar.jpeg',
        'https://user:pass@rickandmortyapi.com/api/character/avatar/1.jpeg',
        'https://rickandmortyapi.com@evil.example/avatar.jpeg',
      ]) {
        test('image "$image" → imageUrl null', () {
          expect(CharacterMapper.toEntity(characterDto(image: image)).imageUrl, isNull);
        });
      }
    });

    group('toPageEntity', () {
      test('next url → nextPage is its page number', () {
        expect(
          CharacterMapper.toPageEntity(pageDto()),
          CharactersPageEntity(characters: [rick], totalCount: 826, nextPage: 2),
        );
      });

      test('next url with name filter → nextPage read by key', () {
        for (final (url, expected) in [
          ('https://rickandmortyapi.com/api/character/?page=7&name=rick', 7),
          ('https://rickandmortyapi.com/api/character/?name=rick&page=12', 12),
        ]) {
          expect(CharacterMapper.toPageEntity(pageDto(next: url)).nextPage, expected, reason: url);
        }
      });

      test('next null → nextPage null', () {
        expect(CharacterMapper.toPageEntity(pageDto(next: null)).nextPage, isNull);
      });

      test('empty results on the last page → no characters, count kept', () {
        expect(
          CharacterMapper.toPageEntity(pageDto(results: [], next: null)),
          const CharactersPageEntity(characters: [], totalCount: 826),
        );
      });

      test('several results → order preserved', () {
        final page = CharacterMapper.toPageEntity(
          pageDto(
            results: [
              characterDto(id: 3, name: 'Summer Smith'),
              characterDto(),
              characterDto(id: 2, name: 'Morty Smith'),
            ],
          ),
        );

        expect(page.characters.map((c) => c.id), [3, 1, 2]);
      });

      test('characters → unmodifiable list', () {
        final page = CharacterMapper.toPageEntity(pageDto());

        expect(() => page.characters.add(rick), throwsUnsupportedError);
      });

      for (final url in [
        'https://rickandmortyapi.com/api/character/?name=rick',
        'https://rickandmortyapi.com/api/character/?page=abc',
      ]) {
        test('next "$url" → FormatException', () {
          expect(() => CharacterMapper.toPageEntity(pageDto(next: url)), throwsFormatException);
        });
      }
    });
  });
}
