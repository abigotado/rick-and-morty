import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';
import 'package:test/test.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/json_fixtures.dart';

void main() {
  group('CharactersService', () {
    late FakeAdapter adapter;
    late CharactersService service;

    void respond({int status = 200, String body = '', Exception? error}) {
      adapter = FakeAdapter(status: status, body: body, error: error);
      service = CharactersService(createApiDio()..httpClientAdapter = adapter);
    }

    void respondJson(Object? json, {int status = 200}) =>
        respond(status: status, body: jsonEncode(json));

    Matcher throwsResponseException(int statusCode) => throwsA(
      isA<ApiResponseException>().having((e) => e.statusCode, 'statusCode', statusCode),
    );

    Matcher throwsFormatExceptionCausedBy(Matcher cause) =>
        throwsA(isA<ApiFormatException>().having((e) => e.cause, 'cause', cause));

    Future<StackTrace?> stackTraceOf(Future<void> Function() call) => call().then(
      (_) => null,
      onError: (Object error, StackTrace stackTrace) => stackTrace,
    );

    group('getCharacters', () {
      test('page only → GET /character/ with the page and no name', () async {
        respondJson(pageJson());

        await service.getCharacters(page: 3);

        final request = adapter.requests.single;
        expect(request.method, 'GET');
        expect(request.uri.toString(), 'https://rickandmortyapi.com/api/character/?page=3');
      });

      test('page and name → both sent as query parameters', () async {
        respondJson(pageJson());

        await service.getCharacters(page: 2, name: 'rick');

        expect(
          adapter.requests.single.uri.toString(),
          'https://rickandmortyapi.com/api/character/?page=2&name=rick',
        );
      });

      test('200 → parses the page', () async {
        respondJson(
          pageJson(
            results: [
              characterJson(id: 5, name: 'Jerry Smith'),
              characterJson(id: 2),
            ],
            next: 'https://rickandmortyapi.com/api/character/?page=3',
          ),
        );

        final page = await service.getCharacters(page: 2);

        expect(page.results.map((c) => c.id), [5, 2]);
        expect(page.results.first.name, 'Jerry Smith');
        expect(page.info.next, 'https://rickandmortyapi.com/api/character/?page=3');
      });

      test('404 → ApiResponseException(404)', () async {
        respondJson({'error': 'There is nothing here'}, status: 404);

        await expectLater(
          service.getCharacters(page: 1, name: 'zzz'),
          throwsResponseException(404),
        );
      });

      for (final status in [429, 500, 503]) {
        test('$status → ApiResponseException($status)', () async {
          respondJson({'error': 'boom'}, status: status);

          await expectLater(service.getCharacters(page: 1), throwsResponseException(status));
        });
      }

      test('bad response → keeps the stack trace from dio', () async {
        respondJson({'error': 'boom'}, status: 500);

        final stackTrace = await stackTraceOf(() => service.getCharacters(page: 1));

        expect(stackTrace.toString(), contains('package:dio/'));
      });

      final transportErrors = <String, Exception>{
        'socket exception': const SocketException('Failed host lookup'),
      };
      for (final type in DioExceptionType.values.where((t) => t != DioExceptionType.badResponse)) {
        transportErrors['dio ${type.name}'] = DioException(
          requestOptions: RequestOptions(),
          type: type,
        );
      }
      for (final MapEntry(key: name, value: error) in transportErrors.entries) {
        test('$name → ApiConnectionException', () async {
          respond(error: error);

          await expectLater(
            service.getCharacters(page: 1),
            throwsA(isA<ApiConnectionException>()),
          );
        });
      }

      test('invalid json → ApiFormatException caused by a FormatException', () async {
        respond(body: '{not json');

        await expectLater(
          service.getCharacters(page: 1),
          throwsFormatExceptionCausedBy(isA<FormatException>()),
        );
      });

      test('missing key → ApiFormatException caused by CheckedFromJsonException', () async {
        respondJson(pageJson()..remove('results'));

        await expectLater(
          service.getCharacters(page: 1),
          throwsFormatExceptionCausedBy(isA<CheckedFromJsonException>()),
        );
      });

      test('missing key → keeps the stack trace of the parser', () async {
        respondJson(pageJson()..remove('results'));

        final stackTrace = await stackTraceOf(() => service.getCharacters(page: 1));

        expect(stackTrace.toString(), contains('characters_page.dto.g.dart'));
      });

      test('json array instead of an object → ApiFormatException', () async {
        respondJson([pageJson()]);

        await expectLater(service.getCharacters(page: 1), throwsA(isA<ApiFormatException>()));
      });

      test('empty body → ApiFormatException caused by a FormatException', () async {
        respond();

        await expectLater(
          service.getCharacters(page: 1),
          throwsFormatExceptionCausedBy(isA<FormatException>()),
        );
      });
    });

    group('getCharacter', () {
      test('id → GET /character/{id} without query', () async {
        respondJson(characterJson(id: 42));

        await service.getCharacter(42);

        final request = adapter.requests.single;
        expect(request.method, 'GET');
        expect(request.uri.toString(), 'https://rickandmortyapi.com/api/character/42');
      });

      test('200 → parses the character', () async {
        respondJson(characterJson(id: 42, name: 'Mr. Meeseeks'));

        final character = await service.getCharacter(42);

        expect(character.id, 42);
        expect(character.name, 'Mr. Meeseeks');
      });

      test('404 → ApiResponseException(404)', () async {
        respondJson({'error': 'Character not found'}, status: 404);

        await expectLater(service.getCharacter(99999), throwsResponseException(404));
      });

      test('connection error → ApiConnectionException', () async {
        respond(
          error: DioException.connectionError(
            requestOptions: RequestOptions(),
            reason: 'Connection refused',
          ),
        );

        await expectLater(service.getCharacter(1), throwsA(isA<ApiConnectionException>()));
      });

      test('missing key → ApiFormatException caused by CheckedFromJsonException', () async {
        respondJson(characterJson()..remove('name'));

        await expectLater(
          service.getCharacter(1),
          throwsFormatExceptionCausedBy(isA<CheckedFromJsonException>()),
        );
      });

      test('json array instead of an object → ApiFormatException', () async {
        respondJson([characterJson()]);

        await expectLater(service.getCharacter(1), throwsA(isA<ApiFormatException>()));
      });

      test('empty body → ApiFormatException caused by a FormatException', () async {
        respond();

        await expectLater(
          service.getCharacter(1),
          throwsFormatExceptionCausedBy(isA<FormatException>()),
        );
      });
    });
  });
}
