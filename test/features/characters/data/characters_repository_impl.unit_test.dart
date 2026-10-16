import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty/core/failure.dart';
import 'package:rick_and_morty/features/characters/data/characters_api.dart';
import 'package:rick_and_morty/features/characters/data/characters_repository_impl.dart';
import 'package:rick_and_morty/features/characters/domain/characters_page.dart';

import '../../../helpers/character_fixtures.dart';

class MockCharactersApi extends Mock implements CharactersApi {}

DioException badResponse(int status, {String path = '/character/'}) {
  final options = RequestOptions(path: path);
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(requestOptions: options, statusCode: status),
  );
}

DioException transportError(DioExceptionType type) {
  return DioException(
    requestOptions: RequestOptions(path: '/character/'),
    type: type,
  );
}

void main() {
  group('CharactersRepositoryImpl', () {
    late MockCharactersApi api;
    late CharactersRepositoryImpl repository;

    setUp(() {
      api = MockCharactersApi();
      repository = CharactersRepositoryImpl(api);
    });

    group('getCharacters', () {
      void stubListResponse(Map<String, dynamic> json) {
        when(
          () => api.fetchCharacters(
            page: any(named: 'page'),
            name: any(named: 'name'),
          ),
        ).thenAnswer((_) async => json);
      }

      void stubList(Object error) {
        when(
          () => api.fetchCharacters(
            page: any(named: 'page'),
            name: any(named: 'name'),
          ),
        ).thenThrow(error);
      }

      test('success → maps the page', () async {
        stubListResponse(pageJson());

        final page = await repository.getCharacters();

        expect(page, const CharactersPage(characters: [rick], nextPage: 2));
        expect(page.hasMore, isTrue);
      });

      test('last page → hasMore false', () async {
        stubListResponse(pageJson(next: null));

        final page = await repository.getCharacters(page: 2);

        expect(page.nextPage, isNull);
        expect(page.hasMore, isFalse);
      });

      test('page and name → passed through to the api', () async {
        when(
          () => api.fetchCharacters(page: 4, name: 'morty'),
        ).thenAnswer((_) async => pageJson());

        await repository.getCharacters(page: 4, name: 'morty');

        verify(() => api.fetchCharacters(page: 4, name: 'morty')).called(1);
      });

      test('default arguments → first page without a name', () async {
        stubListResponse(pageJson());

        await repository.getCharacters();

        final captured = verify(
          () => api.fetchCharacters(
            page: captureAny(named: 'page'),
            name: captureAny(named: 'name'),
          ),
        ).captured;
        expect(captured, [1, '']);
      });

      test('404 → empty page', () async {
        stubList(badResponse(404));

        final page = await repository.getCharacters(name: 'zzz');

        expect(page, const CharactersPage.empty());
        expect(page.hasMore, isFalse);
      });

      test('404 past the last page → empty page', () async {
        stubList(badResponse(404));

        final page = await repository.getCharacters(page: 43);

        expect(page, const CharactersPage.empty());
      });

      test('500 → ServerFailure with status code', () async {
        stubList(badResponse(500));

        await expectLater(
          repository.getCharacters(),
          throwsA(const ServerFailure(500)),
        );
      });

      test('other 4xx → ServerFailure with status code', () async {
        stubList(badResponse(429));

        await expectLater(
          repository.getCharacters(),
          throwsA(const ServerFailure(429)),
        );
      });

      test('transport errors → NetworkFailure', () async {
        for (final type in [
          DioExceptionType.connectionError,
          DioExceptionType.connectionTimeout,
          DioExceptionType.sendTimeout,
          DioExceptionType.receiveTimeout,
          DioExceptionType.transformTimeout,
          DioExceptionType.badCertificate,
          DioExceptionType.cancel,
          DioExceptionType.unknown,
        ]) {
          stubList(transportError(type));

          await expectLater(
            repository.getCharacters(),
            throwsA(const NetworkFailure()),
            reason: '$type',
          );
        }
      });

      test('undecodable body → ServerFailure', () async {
        stubList(
          DioException(
            requestOptions: RequestOptions(path: '/character/'),
            error: const FormatException('Unexpected character'),
          ),
        );

        await expectLater(
          repository.getCharacters(),
          throwsA(const ServerFailure()),
        );
      });

      test('FormatException from the api → ServerFailure', () async {
        stubList(const FormatException('Empty response body'));

        await expectLater(
          repository.getCharacters(),
          throwsA(const ServerFailure()),
        );
      });

      test('malformed payload → ServerFailure', () async {
        stubListResponse(pageJson()..remove('results'));

        await expectLater(
          repository.getCharacters(),
          throwsA(const ServerFailure()),
        );
      });
    });

    group('getCharacter', () {
      void stubById(Object error) {
        when(() => api.fetchCharacter(any())).thenThrow(error);
      }

      test('success → maps the character', () async {
        when(() => api.fetchCharacter(1)).thenAnswer((_) async => characterJson());

        final character = await repository.getCharacter(1);

        expect(character, rick);
        verify(() => api.fetchCharacter(1)).called(1);
      });

      test('404 → NotFoundFailure', () async {
        stubById(badResponse(404, path: '/character/999'));

        await expectLater(
          repository.getCharacter(999),
          throwsA(const NotFoundFailure()),
        );
      });

      test('500 → ServerFailure with status code', () async {
        stubById(badResponse(500, path: '/character/1'));

        await expectLater(
          repository.getCharacter(1),
          throwsA(const ServerFailure(500)),
        );
      });

      test('transport errors → NetworkFailure', () async {
        for (final type in [
          DioExceptionType.connectionError,
          DioExceptionType.connectionTimeout,
          DioExceptionType.sendTimeout,
          DioExceptionType.receiveTimeout,
          DioExceptionType.transformTimeout,
          DioExceptionType.badCertificate,
          DioExceptionType.cancel,
          DioExceptionType.unknown,
        ]) {
          stubById(transportError(type));

          await expectLater(
            repository.getCharacter(1),
            throwsA(const NetworkFailure()),
            reason: '$type',
          );
        }
      });

      test('undecodable body → ServerFailure', () async {
        stubById(
          DioException(
            requestOptions: RequestOptions(path: '/character/1'),
            error: const FormatException('Unexpected character'),
          ),
        );

        await expectLater(
          repository.getCharacter(1),
          throwsA(const ServerFailure()),
        );
      });

      test('FormatException from the api → ServerFailure', () async {
        stubById(const FormatException('Empty response body'));

        await expectLater(
          repository.getCharacter(1),
          throwsA(const ServerFailure()),
        );
      });

      test('malformed payload → ServerFailure', () async {
        when(
          () => api.fetchCharacter(1),
        ).thenAnswer((_) async => characterJson()..remove('name'));

        await expectLater(
          repository.getCharacter(1),
          throwsA(const ServerFailure()),
        );
      });
    });
  });
}
