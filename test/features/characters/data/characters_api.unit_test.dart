import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/features/characters/data/characters_api.dart';

import '../../../helpers/character_fixtures.dart';
import '../../../helpers/fake_http_adapter.dart';

void main() {
  group('CharactersApi', () {
    late FakeAdapter adapter;
    late CharactersApi api;

    void respond({required int status, Object? body}) {
      adapter = FakeAdapter(status: status, body: body == null ? '' : jsonEncode(body));
      final dio = Dio(BaseOptions(baseUrl: 'https://rickandmortyapi.com/api'))
        ..httpClientAdapter = adapter;
      api = CharactersApi(dio);
    }

    group('fetchCharacters', () {
      test('page only → requests /character/ with page and no name', () async {
        respond(status: 200, body: pageJson());

        await api.fetchCharacters(page: 3);

        final request = adapter.requests.single;
        expect(request.method, 'GET');
        expect(request.uri.toString(), 'https://rickandmortyapi.com/api/character/?page=3');
        expect(request.queryParameters, {'page': 3});
      });

      test('non-empty name → sent as name parameter', () async {
        respond(status: 200, body: pageJson());

        await api.fetchCharacters(page: 2, name: 'rick');

        expect(adapter.requests.single.queryParameters, {'page': 2, 'name': 'rick'});
      });

      test('name with spaces → percent-encoded in the url', () async {
        respond(status: 200, body: pageJson());

        await api.fetchCharacters(page: 1, name: 'rick sanchez');

        expect(adapter.requests.single.uri.queryParameters['name'], 'rick sanchez');
        expect(adapter.requests.single.uri.query, isNot(contains(' ')));
      });

      test('200 → returns the decoded body', () async {
        final body = pageJson(results: [characterJson(id: 5, name: 'Jerry Smith')]);
        respond(status: 200, body: body);

        final result = await api.fetchCharacters(page: 1);

        expect(result, body);
      });

      test('404 → DioException with 404 response', () async {
        respond(status: 404, body: {'error': 'There is nothing here'});

        await expectLater(
          api.fetchCharacters(page: 1, name: 'zzz'),
          throwsA(
            isA<DioException>()
                .having((e) => e.type, 'type', DioExceptionType.badResponse)
                .having((e) => e.response?.statusCode, 'statusCode', 404),
          ),
        );
      });

      test('500 → DioException with 500 response', () async {
        respond(status: 500, body: {'error': 'boom'});

        await expectLater(
          api.fetchCharacters(page: 1),
          throwsA(
            isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 500),
          ),
        );
      });

      test('empty body → FormatException', () async {
        respond(status: 200);

        await expectLater(api.fetchCharacters(page: 1), throwsFormatException);
      });

      test('invalid json → DioException wrapping a FormatException', () async {
        adapter = FakeAdapter(status: 200, body: '{not json');
        api = CharactersApi(
          Dio(BaseOptions(baseUrl: 'https://rickandmortyapi.com/api'))..httpClientAdapter = adapter,
        );

        await expectLater(
          api.fetchCharacters(page: 1),
          throwsA(
            isA<DioException>()
                .having((e) => e.type, 'type', DioExceptionType.unknown)
                .having((e) => e.error, 'error', isA<FormatException>()),
          ),
        );
      });

      test('array body → FormatException', () async {
        respond(status: 200, body: [1, 2]);

        await expectLater(api.fetchCharacters(page: 1), throwsFormatException);
      });
    });

    group('fetchCharacter', () {
      test('id → requests /character/{id} without query', () async {
        respond(status: 200, body: characterJson(id: 42));

        await api.fetchCharacter(42);

        final request = adapter.requests.single;
        expect(request.method, 'GET');
        expect(request.uri.toString(), 'https://rickandmortyapi.com/api/character/42');
        expect(request.queryParameters, isEmpty);
      });

      test('200 → returns the decoded body', () async {
        final body = characterJson(id: 42, name: 'Mr. Meeseeks');
        respond(status: 200, body: body);

        final result = await api.fetchCharacter(42);

        expect(result, body);
      });

      test('404 → DioException with 404 response', () async {
        respond(status: 404, body: {'error': 'Character not found'});

        await expectLater(
          api.fetchCharacter(99999),
          throwsA(
            isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 404),
          ),
        );
      });

      test('empty body → FormatException', () async {
        respond(status: 200);

        await expectLater(api.fetchCharacter(1), throwsFormatException);
      });
    });
  });
}
