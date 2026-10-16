import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty/core/failure.dart';
import 'package:rick_and_morty/features/characters/domain/characters_page.dart';
import 'package:rick_and_morty/features/characters/domain/characters_repository.dart';
import 'package:rick_and_morty/features/characters/presentation/list/bloc/characters_bloc.dart';

import '../../../../../helpers/character_fixtures.dart';

class MockCharactersRepository extends Mock implements CharactersRepository {}

void main() {
  late MockCharactersRepository repository;
  late Completer<CharactersPage> pendingPage;

  final firstPage = CharactersPage(
    characters: [buildCharacter(1), buildCharacter(2)],
    nextPage: 2,
  );
  final secondPage = CharactersPage(
    characters: [buildCharacter(3), buildCharacter(4)],
    nextPage: 3,
  );
  final lastPage = CharactersPage(characters: [buildCharacter(3)]);

  final loadedState = CharactersState(
    status: CharactersStatus.success,
    characters: firstPage.characters,
    nextPage: 2,
  );
  final loadedLastPageState = CharactersState(
    status: CharactersStatus.success,
    characters: firstPage.characters,
  );
  const loadingState = CharactersState(status: CharactersStatus.loading);
  const networkFailure = NetworkFailure();
  const failedFirstPageState = CharactersState(
    status: CharactersStatus.failure,
    failure: networkFailure,
  );
  final failedNextPageState = CharactersState(
    status: CharactersStatus.success,
    characters: firstPage.characters,
    nextPage: 2,
    nextPageStatus: NextPageStatus.failure,
  );

  setUp(() {
    repository = MockCharactersRepository();
  });

  CharactersBloc buildBloc() => CharactersBloc(repository);

  group('CharactersBloc', () {
    test('initial state → initial status with no characters', () {
      final bloc = buildBloc();
      addTearDown(bloc.close);

      expect(bloc.state, const CharactersState());
      expect(bloc.state.hasMore, isFalse);
    });

    group('CharactersStarted', () {
      blocTest<CharactersBloc, CharactersState>(
        'first page loads → loading then success with the next page',
        build: buildBloc,
        setUp: () => when(() => repository.getCharacters()).thenAnswer((_) async => firstPage),
        act: (bloc) => bloc.add(const CharactersStarted()),
        expect: () => [
          loadingState,
          loadedState,
        ],
        verify: (_) {
          verify(() => repository.getCharacters()).called(1);
        },
      );

      blocTest<CharactersBloc, CharactersState>(
        'last page loads → success with hasMore false',
        build: buildBloc,
        setUp: () => when(() => repository.getCharacters()).thenAnswer(
          (_) async => CharactersPage(characters: firstPage.characters),
        ),
        act: (bloc) => bloc.add(const CharactersStarted()),
        expect: () => [
          loadingState,
          loadedLastPageState,
        ],
        verify: (bloc) {
          expect(bloc.state.hasMore, isFalse);
        },
      );

      blocTest<CharactersBloc, CharactersState>(
        'empty page → success with no characters',
        build: buildBloc,
        setUp: () => when(() => repository.getCharacters()).thenAnswer(
          (_) async => const CharactersPage.empty(),
        ),
        act: (bloc) => bloc.add(const CharactersStarted()),
        expect: () => [
          loadingState,
          const CharactersState(status: CharactersStatus.success),
        ],
      );

      blocTest<CharactersBloc, CharactersState>(
        'NetworkFailure → loading then failure state carrying the failure',
        build: buildBloc,
        setUp: () => when(() => repository.getCharacters()).thenThrow(networkFailure),
        act: (bloc) => bloc.add(const CharactersStarted()),
        expect: () => [
          loadingState,
          failedFirstPageState,
        ],
      );
    });

    group('CharactersNextPageRequested', () {
      blocTest<CharactersBloc, CharactersState>(
        'success state with more pages → appends the page and advances nextPage',
        build: buildBloc,
        seed: () => loadedState,
        setUp: () => when(
          () => repository.getCharacters(page: 2),
        ).thenAnswer((_) async => secondPage),
        act: (bloc) => bloc.add(const CharactersNextPageRequested()),
        expect: () => [
          CharactersState(
            status: CharactersStatus.success,
            characters: firstPage.characters,
            nextPage: 2,
            nextPageStatus: NextPageStatus.loading,
          ),
          CharactersState(
            status: CharactersStatus.success,
            characters: [...firstPage.characters, ...secondPage.characters],
            nextPage: 3,
          ),
        ],
        verify: (_) {
          verify(() => repository.getCharacters(page: 2)).called(1);
        },
      );

      blocTest<CharactersBloc, CharactersState>(
        'final page → appends the page and sets hasMore false',
        build: buildBloc,
        seed: () => loadedState,
        setUp: () => when(
          () => repository.getCharacters(page: 2),
        ).thenAnswer((_) async => lastPage),
        act: (bloc) => bloc.add(const CharactersNextPageRequested()),
        verify: (bloc) {
          expect(bloc.state.characters, [...firstPage.characters, ...lastPage.characters]);
          expect(bloc.state.hasMore, isFalse);
          expect(bloc.state.nextPageStatus, NextPageStatus.idle);
        },
      );

      blocTest<CharactersBloc, CharactersState>(
        'requested twice while loading → repository called once and the page appended once',
        build: buildBloc,
        seed: () => loadedState,
        setUp: () {
          pendingPage = Completer<CharactersPage>();
          when(
            () => repository.getCharacters(page: 2),
          ).thenAnswer((_) => pendingPage.future);
        },
        act: (bloc) async {
          bloc
            ..add(const CharactersNextPageRequested())
            ..add(const CharactersNextPageRequested());
          await pumpEventQueue();
          pendingPage.complete(secondPage);
        },
        verify: (bloc) {
          expect(bloc.state.characters, [...firstPage.characters, ...secondPage.characters]);
          verify(() => repository.getCharacters(page: 2)).called(1);
        },
      );

      blocTest<CharactersBloc, CharactersState>(
        'hasMore false → no request and no new state',
        build: buildBloc,
        seed: () => loadedLastPageState,
        act: (bloc) => bloc.add(const CharactersNextPageRequested()),
        expect: () => <CharactersState>[],
        verify: (_) {
          verifyNever(
            () => repository.getCharacters(
              page: any(named: 'page'),
              name: any(named: 'name'),
            ),
          );
        },
      );

      for (final status in [
        CharactersStatus.initial,
        CharactersStatus.loading,
        CharactersStatus.failure,
      ]) {
        blocTest<CharactersBloc, CharactersState>(
          '${status.name} status with a stale nextPage → no request and no new state',
          build: buildBloc,
          seed: () => CharactersState(status: status, nextPage: 2),
          act: (bloc) => bloc.add(const CharactersNextPageRequested()),
          expect: () => <CharactersState>[],
          verify: (_) {
            verifyNever(
              () => repository.getCharacters(
                page: any(named: 'page'),
                name: any(named: 'name'),
              ),
            );
          },
        );
      }

      blocTest<CharactersBloc, CharactersState>(
        'next page fails → items stay and nextPageStatus is failure',
        build: buildBloc,
        seed: () => loadedState,
        setUp: () => when(
          () => repository.getCharacters(page: 2),
        ).thenThrow(networkFailure),
        act: (bloc) => bloc.add(const CharactersNextPageRequested()),
        expect: () => [
          CharactersState(
            status: CharactersStatus.success,
            characters: firstPage.characters,
            nextPage: 2,
            nextPageStatus: NextPageStatus.loading,
          ),
          failedNextPageState,
        ],
      );

      blocTest<CharactersBloc, CharactersState>(
        'after a next-page failure → further requests do nothing until retried',
        build: buildBloc,
        seed: () => failedNextPageState,
        act: (bloc) => bloc
          ..add(const CharactersNextPageRequested())
          ..add(const CharactersNextPageRequested()),
        expect: () => <CharactersState>[],
        verify: (_) {
          verifyNever(
            () => repository.getCharacters(
              page: any(named: 'page'),
              name: any(named: 'name'),
            ),
          );
        },
      );

      blocTest<CharactersBloc, CharactersState>(
        'empty page for page > 1 → items kept and hasMore false instead of the empty state',
        build: buildBloc,
        seed: () => loadedState,
        setUp: () => when(
          () => repository.getCharacters(page: 2),
        ).thenAnswer((_) async => const CharactersPage.empty()),
        act: (bloc) => bloc.add(const CharactersNextPageRequested()),
        verify: (bloc) {
          expect(bloc.state.status, CharactersStatus.success);
          expect(bloc.state.characters, firstPage.characters);
          expect(bloc.state.hasMore, isFalse);
          expect(bloc.state.nextPageStatus, NextPageStatus.idle);
        },
      );
    });

    group('CharactersRetried', () {
      blocTest<CharactersBloc, CharactersState>(
        'after a first-page failure → reloads the first page',
        build: buildBloc,
        seed: () => failedFirstPageState,
        setUp: () => when(() => repository.getCharacters()).thenAnswer((_) async => firstPage),
        act: (bloc) => bloc.add(const CharactersRetried()),
        expect: () => [
          loadingState,
          loadedState,
        ],
        verify: (_) {
          verify(() => repository.getCharacters()).called(1);
        },
      );

      blocTest<CharactersBloc, CharactersState>(
        'after a first-page failure that fails again → ends in failure',
        build: buildBloc,
        seed: () => failedFirstPageState,
        setUp: () => when(() => repository.getCharacters()).thenThrow(networkFailure),
        act: (bloc) => bloc.add(const CharactersRetried()),
        expect: () => [
          loadingState,
          failedFirstPageState,
        ],
      );

      blocTest<CharactersBloc, CharactersState>(
        'after a next-page failure → reloads that page and appends it',
        build: buildBloc,
        seed: () => failedNextPageState,
        setUp: () => when(
          () => repository.getCharacters(page: 2),
        ).thenAnswer((_) async => secondPage),
        act: (bloc) => bloc.add(const CharactersRetried()),
        expect: () => [
          CharactersState(
            status: CharactersStatus.success,
            characters: firstPage.characters,
            nextPage: 2,
            nextPageStatus: NextPageStatus.loading,
          ),
          CharactersState(
            status: CharactersStatus.success,
            characters: [...firstPage.characters, ...secondPage.characters],
            nextPage: 3,
          ),
        ],
        verify: (_) {
          verify(() => repository.getCharacters(page: 2)).called(1);
          verifyNever(() => repository.getCharacters());
        },
      );

      blocTest<CharactersBloc, CharactersState>(
        'after a next-page failure that fails again → items stay and failure remains',
        build: buildBloc,
        seed: () => failedNextPageState,
        setUp: () => when(
          () => repository.getCharacters(page: 2),
        ).thenThrow(networkFailure),
        act: (bloc) => bloc.add(const CharactersRetried()),
        verify: (bloc) {
          expect(bloc.state, failedNextPageState);
        },
      );

      blocTest<CharactersBloc, CharactersState>(
        'nothing failed → no request and no new state',
        build: buildBloc,
        seed: () => loadedState,
        act: (bloc) => bloc.add(const CharactersRetried()),
        expect: () => <CharactersState>[],
        verify: (_) {
          verifyNever(
            () => repository.getCharacters(
              page: any(named: 'page'),
              name: any(named: 'name'),
            ),
          );
        },
      );
    });
  });
}
