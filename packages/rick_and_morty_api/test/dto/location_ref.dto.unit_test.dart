import 'package:json_annotation/json_annotation.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';
import 'package:test/test.dart';

import '../helpers/json_fixtures.dart';

void main() {
  group('LocationRefDTO', () {
    group('fromJson', () {
      test('name and url → both read', () {
        final dto = LocationRefDTO.fromJson(locationJson());

        expect(dto.name, 'Earth (C-137)');
        expect(dto.url, 'https://rickandmortyapi.com/api/location/1');
      });

      test('empty url → kept as an empty string', () {
        expect(LocationRefDTO.fromJson(locationJson(url: '')).url, '');
      });

      test('missing url → CheckedFromJsonException', () {
        expect(
          () => LocationRefDTO.fromJson({'name': 'unknown'}),
          throwsA(isA<CheckedFromJsonException>()),
        );
      });

      test('non-string name → CheckedFromJsonException', () {
        expect(
          () => LocationRefDTO.fromJson({'name': 5, 'url': ''}),
          throwsA(isA<CheckedFromJsonException>()),
        );
      });
    });
  });
}
