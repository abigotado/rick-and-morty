import 'package:json_annotation/json_annotation.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';
import 'package:test/test.dart';

import '../helpers/json_fixtures.dart';

void main() {
  group('CharactersPageDTO', () {
    group('fromJson', () {
      test('full payload → info and results in order', () {
        final dto = CharactersPageDTO.fromJson(
          pageJson(
            results: [
              characterJson(id: 3, name: 'Summer Smith'),
              characterJson(),
              characterJson(id: 2, name: 'Morty Smith'),
            ],
          ),
        );

        expect(dto.info.next, 'https://rickandmortyapi.com/api/character/?page=2');
        expect(dto.results.map((c) => c.id), [3, 1, 2]);
      });

      test('empty results → empty list', () {
        expect(CharactersPageDTO.fromJson(pageJson(results: [])).results, isEmpty);
      });

      final malformed = <String, Map<String, dynamic> Function()>{
        'missing info': () => pageJson()..remove('info'),
        'info of wrong type': () => pageJson()..['info'] = 'nope',
        'missing results': () => pageJson()..remove('results'),
        'results of wrong type': () => pageJson()..['results'] = <String, dynamic>{},
        'non-object entry in results': () => pageJson()..['results'] = [characterJson(), 'rick'],
        'malformed character in results': () =>
            pageJson(results: [characterJson(), characterJson(id: 2)..remove('name')]),
      };
      for (final MapEntry(key: description, value: json) in malformed.entries) {
        test('$description → CheckedFromJsonException', () {
          expect(
            () => CharactersPageDTO.fromJson(json()),
            throwsA(isA<CheckedFromJsonException>()),
          );
        });
      }
    });
  });
}
