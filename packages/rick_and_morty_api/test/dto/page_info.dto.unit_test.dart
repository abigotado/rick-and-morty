import 'package:json_annotation/json_annotation.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';
import 'package:test/test.dart';

import '../helpers/json_fixtures.dart';

void main() {
  group('PageInfoDTO', () {
    group('fromJson', () {
      test('full payload → every field read', () {
        final dto = PageInfoDTO.fromJson(pageInfoJson());

        expect(dto.count, 826);
        expect(dto.pages, 42);
        expect(dto.next, 'https://rickandmortyapi.com/api/character/?page=2');
      });

      test('next null → parsed as the last page', () {
        expect(PageInfoDTO.fromJson(pageInfoJson(next: null)).next, isNull);
      });

      test('missing next → CheckedFromJsonException', () {
        expect(
          () => PageInfoDTO.fromJson(pageInfoJson()..remove('next')),
          throwsA(isA<CheckedFromJsonException>().having((e) => e.key, 'key', 'next')),
        );
      });

      test('next of wrong type → CheckedFromJsonException', () {
        expect(
          () => PageInfoDTO.fromJson(pageInfoJson()..['next'] = 2),
          throwsA(isA<CheckedFromJsonException>()),
        );
      });
    });
  });
}
