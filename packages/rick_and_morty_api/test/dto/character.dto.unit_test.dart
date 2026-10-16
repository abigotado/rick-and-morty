import 'package:json_annotation/json_annotation.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';
import 'package:test/test.dart';

import '../helpers/json_fixtures.dart';

void main() {
  group('CharacterDTO', () {
    group('fromJson', () {
      test('full payload → every field read', () {
        final dto = CharacterDTO.fromJson(characterJson(type: 'Genetic experiment'));

        expect(dto.id, 1);
        expect(dto.name, 'Rick Sanchez');
        expect(dto.status, 'Alive');
        expect(dto.species, 'Human');
        expect(dto.type, 'Genetic experiment');
        expect(dto.gender, 'Male');
        expect(dto.origin.name, 'Earth (C-137)');
        expect(dto.origin.url, 'https://rickandmortyapi.com/api/location/1');
        expect(dto.location.name, 'Citadel of Ricks');
        expect(dto.location.url, 'https://rickandmortyapi.com/api/location/3');
        expect(dto.image, 'https://rickandmortyapi.com/api/character/avatar/1.jpeg');
      });

      test('empty type → kept as an empty string', () {
        expect(CharacterDTO.fromJson(characterJson()).type, '');
      });

      test('unknown status string → kept as is', () {
        expect(CharacterDTO.fromJson(characterJson(status: 'zombie')).status, 'zombie');
      });

      test('origin unknown with empty url → parsed', () {
        final dto = CharacterDTO.fromJson(
          characterJson(
            origin: locationJson(name: 'unknown', url: ''),
          ),
        );

        expect(dto.origin.name, 'unknown');
        expect(dto.origin.url, '');
      });

      test('missing key → CheckedFromJsonException naming the key', () {
        expect(
          () => CharacterDTO.fromJson(characterJson()..remove('name')),
          throwsA(isA<CheckedFromJsonException>().having((e) => e.key, 'key', 'name')),
        );
      });

      test('value of wrong type → CheckedFromJsonException', () {
        expect(
          () => CharacterDTO.fromJson(characterJson()..['id'] = '1'),
          throwsA(isA<CheckedFromJsonException>()),
        );
      });

      test('origin without name → CheckedFromJsonException', () {
        expect(
          () => CharacterDTO.fromJson(characterJson(origin: {'url': ''})),
          throwsA(isA<CheckedFromJsonException>()),
        );
      });
    });
  });
}
