import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/features/characters/data/character_mapper.dart';
import 'package:rick_and_morty/features/characters/domain/character.dart';
import 'package:rick_and_morty/features/characters/domain/characters_page.dart';

import '../../../helpers/character_fixtures.dart';

void main() {
  group('CharacterMapper', () {
    group('fromJson', () {
      test('full payload → maps every field', () {
        expect(CharacterMapper.fromJson(characterJson()), rick);
      });

      test('non-empty type → kept', () {
        final character = CharacterMapper.fromJson(characterJson(type: 'Genetic experiment'));

        expect(character.type, 'Genetic experiment');
      });

      test('known statuses → mapped regardless of case', () {
        const expected = {
          'Alive': CharacterStatus.alive,
          'alive': CharacterStatus.alive,
          'ALIVE': CharacterStatus.alive,
          'Dead': CharacterStatus.dead,
          'dead': CharacterStatus.dead,
          'unknown': CharacterStatus.unknown,
          'Unknown': CharacterStatus.unknown,
        };

        for (final entry in expected.entries) {
          final character = CharacterMapper.fromJson(characterJson(status: entry.key));
          expect(character.status, entry.value, reason: 'status "${entry.key}"');
        }
      });

      test('unexpected status string → unknown', () {
        for (final status in ['zombie', '', ' ']) {
          final character = CharacterMapper.fromJson(characterJson(status: status));
          expect(character.status, CharacterStatus.unknown, reason: 'status "$status"');
        }
      });

      test('origin named unknown with empty url → keeps the name', () {
        final character = CharacterMapper.fromJson(
          characterJson(originName: 'unknown', originUrl: '', locationName: 'unknown'),
        );

        expect(character.origin, 'unknown');
        expect(character.location, 'unknown');
      });

      test('missing key → FormatException', () {
        for (final key in [
          'id',
          'name',
          'status',
          'species',
          'type',
          'gender',
          'origin',
          'location',
          'image',
        ]) {
          final json = characterJson()..remove(key);

          expect(
            () => CharacterMapper.fromJson(json),
            throwsFormatException,
            reason: 'missing "$key"',
          );
        }
      });

      test('wrong field type → FormatException', () {
        final badValues = <String, Object?>{
          'id': '1',
          'name': 42,
          'status': null,
          'species': ['Human'],
          'type': null,
          'gender': 1,
          'origin': 'Earth',
          'location': 'Citadel',
          'image': 7,
        };

        for (final entry in badValues.entries) {
          final json = characterJson()..[entry.key] = entry.value;

          expect(
            () => CharacterMapper.fromJson(json),
            throwsFormatException,
            reason: 'bad "${entry.key}"',
          );
        }
      });

      test('origin without name → FormatException', () {
        final json = characterJson()..['origin'] = <String, dynamic>{'url': ''};

        expect(() => CharacterMapper.fromJson(json), throwsFormatException);
      });

      test('location with non-string name → FormatException', () {
        final json = characterJson()..['location'] = <String, dynamic>{'name': 5};

        expect(() => CharacterMapper.fromJson(json), throwsFormatException);
      });
    });

    group('pageFromJson', () {
      test('next url → nextPage is the page number', () {
        final page = CharacterMapper.pageFromJson(pageJson());

        expect(page, const CharactersPage(characters: [rick], nextPage: 2));
        expect(page.hasMore, isTrue);
      });

      test('next url with name filter → nextPage ignores other parameters', () {
        final page = CharacterMapper.pageFromJson(
          pageJson(next: 'https://rickandmortyapi.com/api/character/?page=7&name=rick'),
        );

        expect(page.nextPage, 7);
      });

      test('next url with page after name → nextPage is read by key', () {
        final page = CharacterMapper.pageFromJson(
          pageJson(next: 'https://rickandmortyapi.com/api/character/?name=rick&page=12'),
        );

        expect(page.nextPage, 12);
      });

      test('null next → nextPage null and hasMore false', () {
        final page = CharacterMapper.pageFromJson(pageJson(next: null));

        expect(page.nextPage, isNull);
        expect(page.hasMore, isFalse);
      });

      test('empty results → empty character list', () {
        final page = CharacterMapper.pageFromJson(pageJson(results: [], next: null));

        expect(page, const CharactersPage.empty());
      });

      test('several results → order preserved', () {
        final page = CharacterMapper.pageFromJson(
          pageJson(
            results: [
              characterJson(id: 3, name: 'Summer Smith'),
              characterJson(),
              characterJson(id: 2, name: 'Morty Smith'),
            ],
          ),
        );

        expect(page.characters.map((c) => c.id), [3, 1, 2]);
      });

      test('next url without page → FormatException', () {
        expect(
          () => CharacterMapper.pageFromJson(
            pageJson(next: 'https://rickandmortyapi.com/api/character/?name=rick'),
          ),
          throwsFormatException,
        );
      });

      test('next url with non-numeric page → FormatException', () {
        expect(
          () => CharacterMapper.pageFromJson(
            pageJson(next: 'https://rickandmortyapi.com/api/character/?page=abc'),
          ),
          throwsFormatException,
        );
      });

      test('missing info → FormatException', () {
        final json = pageJson()..remove('info');

        expect(() => CharacterMapper.pageFromJson(json), throwsFormatException);
      });

      test('info of wrong type → FormatException', () {
        final json = pageJson()..['info'] = 'nope';

        expect(() => CharacterMapper.pageFromJson(json), throwsFormatException);
      });

      test('next of wrong type → FormatException', () {
        final json = pageJson();
        (json['info'] as Map<String, dynamic>)['next'] = 2;

        expect(() => CharacterMapper.pageFromJson(json), throwsFormatException);
      });

      test('missing next → FormatException', () {
        final json = pageJson();
        (json['info'] as Map<String, dynamic>).remove('next');

        expect(() => CharacterMapper.pageFromJson(json), throwsFormatException);
      });

      test('missing results → FormatException', () {
        final json = pageJson()..remove('results');

        expect(() => CharacterMapper.pageFromJson(json), throwsFormatException);
      });

      test('results of wrong type → FormatException', () {
        final json = pageJson()..['results'] = <String, dynamic>{};

        expect(() => CharacterMapper.pageFromJson(json), throwsFormatException);
      });

      test('non-object entry in results → FormatException', () {
        final json = pageJson()..['results'] = [characterJson(), 'rick'];

        expect(() => CharacterMapper.pageFromJson(json), throwsFormatException);
      });

      test('malformed character in results → FormatException', () {
        final json = pageJson(results: [characterJson(), characterJson(id: 2)..remove('name')]);

        expect(() => CharacterMapper.pageFromJson(json), throwsFormatException);
      });
    });
  });
}
