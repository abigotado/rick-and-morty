import 'package:characters_data/characters_data.dart';
import 'package:characters_domain/characters_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';
import 'package:test/test.dart';

import '../helpers/fixtures.dart';

class _MockCharactersService extends Mock implements ICharactersService {}

void main() {
  group('CharactersRepository', () {
    late _MockCharactersService service;
    late CharactersRepository repository;

    setUp(() {
      service = _MockCharactersService();
      repository = CharactersRepository(service);
    });

    Future<StackTrace?> stackTraceOf(Future<void> Function() call) => call().then(
      (_) => null,
      onError: (Object error, StackTrace stackTrace) => stackTrace,
    );

    group('getCharacters', () {
      void stubList(Future<CharactersPageDTO> Function() answer) => when(
        () => service.getCharacters(
          page: any(named: 'page'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) => answer());

      test('success → maps the page', () async {
        stubList(() async => pageDto());

        expect(
          await repository.getCharacters(),
          CharactersPageEntity(characters: [rick], nextPage: 2),
        );
      });

      test('page and name → passed through to the service', () async {
        stubList(() async => pageDto());

        await repository.getCharacters(page: 4, name: 'morty');

        verify(() => service.getCharacters(page: 4, name: 'morty')).called(1);
      });

      test('default arguments → first page without a name', () async {
        stubList(() async => pageDto());

        await repository.getCharacters();

        verify(() => service.getCharacters(page: 1)).called(1);
      });

      test('404 past the last page (page: 43) → empty page', () async {
        stubList(() => throw const ApiResponseException(404));

        expect(await repository.getCharacters(page: 43), const CharactersPageEntity.empty());
        verify(() => service.getCharacters(page: 43)).called(1);
      });

      for (final status in [429, 500, null]) {
        test('response $status → ServerFailure($status)', () async {
          stubList(() => throw ApiResponseException(status));

          await expectLater(repository.getCharacters(), throwsA(ServerFailure(status)));
        });
      }

      test('connection error → NetworkFailure', () async {
        stubList(() => throw const ApiConnectionException());

        await expectLater(repository.getCharacters(), throwsA(const NetworkFailure()));
      });

      test('malformed payload → ServerFailure without code', () async {
        stubList(() => throw const ApiFormatException(FormatException('bad json')));

        await expectLater(repository.getCharacters(), throwsA(const ServerFailure()));
      });

      test('next url without a page number → ServerFailure without code', () async {
        stubList(
          () async => pageDto(next: 'https://rickandmortyapi.com/api/character/?name=rick'),
        );

        await expectLater(repository.getCharacters(), throwsA(const ServerFailure()));
      });

      test('service failure → keeps the original stack trace', () async {
        final original = StackTrace.current;
        stubList(() => Future.error(const ApiConnectionException(), original));

        expect(await stackTraceOf(repository.getCharacters), same(original));
      });
    });

    group('getCharacter', () {
      void stubById(Future<CharacterDTO> Function() answer) =>
          when(() => service.getCharacter(any())).thenAnswer((_) => answer());

      test('success → maps the character for the requested id', () async {
        stubById(() async => characterDto());

        expect(await repository.getCharacter(1), rick);
        verify(() => service.getCharacter(1)).called(1);
      });

      test('404 → NotFoundFailure', () async {
        stubById(() => throw const ApiResponseException(404));

        await expectLater(repository.getCharacter(999), throwsA(const NotFoundFailure()));
      });

      test('404 → keeps the original stack trace', () async {
        final original = StackTrace.current;
        stubById(() => Future.error(const ApiResponseException(404), original));

        expect(await stackTraceOf(() => repository.getCharacter(999)), same(original));
      });

      test('500 → ServerFailure(500)', () async {
        stubById(() => throw const ApiResponseException(500));

        await expectLater(repository.getCharacter(1), throwsA(const ServerFailure(500)));
      });

      test('connection error → NetworkFailure', () async {
        stubById(() => throw const ApiConnectionException());

        await expectLater(repository.getCharacter(1), throwsA(const NetworkFailure()));
      });

      test('malformed payload → ServerFailure without code', () async {
        stubById(() => throw const ApiFormatException(FormatException('bad json')));

        await expectLater(repository.getCharacter(1), throwsA(const ServerFailure()));
      });
    });
  });
}
