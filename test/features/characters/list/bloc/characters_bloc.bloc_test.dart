import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:characters_domain/characters_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty/features/characters/list/bloc/characters_bloc.dart';

import '../../../../helpers/character_fixtures.dart';

class MockCharactersRepository extends Mock implements ICharactersRepository {}

void main() {
  late MockCharactersRepository repository;
  late Completer<CharactersPageEntity> pendingPage;

  final firstPage = CharactersPageEntity(
    totalCount: 0,
    characters: [buildCharacter(1), buildCharacter(2)],
    nextPage: 2,
  );
  final secondPage = CharactersPageEntity(
    totalCount: 0,
    characters: [buildCharacter(3), buildCharacter(4)],
    nextPage: 3,
  );
  final lastPage = CharactersPageEntity(totalCount: 0, characters: [buildCharacter(3)]);

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

  final rickFirstPage = CharactersPageEntity(
    totalCount: 0,
    characters: [
      buildCharacter(10, name: 'Rick'),
      buildCharacter(11, name: 'Rick Prime'),
    ],
    nextPage: 2,
  );
  final rickSecondPage = CharactersPageEntity(
    totalCount: 0,
    characters: [buildCharacter(12, name: 'Doofus Rick')],
    nextPage: 3,
  );
  final mortyPage = CharactersPageEntity(
    totalCount: 0,
    characters: [buildCharacter(20, name: 'Morty')],
  );

  const rickLoadingState = CharactersState(status: CharactersStatus.loading, query: 'rick');
  final rickLoadedState = CharactersState(
    status: CharactersStatus.success,
    characters: rickFirstPage.characters,
    query: 'rick',
    nextPage: 2,
  );
  const searchSettle = Duration(milliseconds: 20);

  setUp(() {
    repository = MockCharactersRepository();
  });

  CharactersBloc buildBloc() => CharactersBloc(charactersRepository: repository);

  CharactersBloc buildSearchBloc() =>
      CharactersBloc(charactersRepository: repository, searchDebounce: Duration.zero);

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
        'first page totalCount → carried into success and kept when the next page is appended',
        build: buildBloc,
        setUp: () {
          when(() => repository.getCharacters()).thenAnswer(
            (_) async => CharactersPageEntity(
              totalCount: 826,
              characters: firstPage.characters,
              nextPage: 2,
            ),
          );
          when(() => repository.getCharacters(page: 2)).thenAnswer(
            (_) async => CharactersPageEntity(
              totalCount: 826,
              characters: secondPage.characters,
              nextPage: 3,
            ),
          );
        },
        act: (bloc) async {
          bloc.add(const CharactersStarted());
          await bloc.stream.firstWhere((state) => state.status == CharactersStatus.success);
          bloc.add(const CharactersNextPageRequested());
        },
        expect: () => [
          loadingState,
          CharactersState(
            status: CharactersStatus.success,
            characters: firstPage.characters,
            totalCount: 826,
            nextPage: 2,
          ),
          CharactersState(
            status: CharactersStatus.success,
            characters: firstPage.characters,
            totalCount: 826,
            nextPage: 2,
            nextPageStatus: NextPageStatus.loading,
          ),
          CharactersState(
            status: CharactersStatus.success,
            characters: [...firstPage.characters, ...secondPage.characters],
            totalCount: 826,
            nextPage: 3,
          ),
        ],
      );

      blocTest<CharactersBloc, CharactersState>(
        'last page loads → success with hasMore false',
        build: buildBloc,
        setUp: () => when(() => repository.getCharacters()).thenAnswer(
          (_) async => CharactersPageEntity(totalCount: 0, characters: firstPage.characters),
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
          (_) async => const CharactersPageEntity.empty(),
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
          pendingPage = Completer<CharactersPageEntity>();
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
        ).thenAnswer((_) async => const CharactersPageEntity.empty()),
        act: (bloc) => bloc.add(const CharactersNextPageRequested()),
        verify: (bloc) {
          expect(bloc.state.status, CharactersStatus.success);
          expect(bloc.state.characters, firstPage.characters);
          expect(bloc.state.hasMore, isFalse);
          expect(bloc.state.nextPageStatus, NextPageStatus.idle);
        },
      );
    });

    group('CharactersQueryChanged', () {
      blocTest<CharactersBloc, CharactersState>(
        'queries typed within the debounce window → one search for the last query',
        build: () => CharactersBloc(
          charactersRepository: repository,
          searchDebounce: const Duration(milliseconds: 50),
        ),
        setUp: () => when(
          () => repository.getCharacters(name: any(named: 'name')),
        ).thenAnswer((_) async => rickFirstPage),
        act: (bloc) => bloc
          ..add(const CharactersQueryChanged('r'))
          ..add(const CharactersQueryChanged('ri'))
          ..add(const CharactersQueryChanged('rick')),
        wait: const Duration(milliseconds: 200),
        expect: () => [rickLoadingState, rickLoadedState],
        verify: (_) {
          verify(() => repository.getCharacters(name: 'rick')).called(1);
          verifyNoMoreInteractions(repository);
        },
      );

      blocTest<CharactersBloc, CharactersState>(
        'padded query over a loaded list → list resets to the first page of the trimmed query',
        build: buildSearchBloc,
        seed: () => loadedState,
        setUp: () => when(
          () => repository.getCharacters(name: 'rick'),
        ).thenAnswer((_) async => rickFirstPage),
        act: (bloc) => bloc.add(const CharactersQueryChanged('  rick  ')),
        wait: searchSettle,
        expect: () => [rickLoadingState, rickLoadedState],
        verify: (_) {
          verify(() => repository.getCharacters(name: 'rick')).called(1);
        },
      );

      blocTest<CharactersBloc, CharactersState>(
        'no match → success with an empty list and the query',
        build: buildSearchBloc,
        setUp: () => when(
          () => repository.getCharacters(name: 'zzz'),
        ).thenAnswer((_) async => const CharactersPageEntity.empty()),
        act: (bloc) => bloc.add(const CharactersQueryChanged('zzz')),
        wait: searchSettle,
        expect: () => [
          const CharactersState(status: CharactersStatus.loading, query: 'zzz'),
          const CharactersState(status: CharactersStatus.success, query: 'zzz'),
        ],
      );

      blocTest<CharactersBloc, CharactersState>(
        'same query while loaded → no request and no new state',
        build: buildSearchBloc,
        seed: () => rickLoadedState,
        act: (bloc) => bloc.add(const CharactersQueryChanged(' rick')),
        wait: searchSettle,
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
        'same query after a failure → reloads it',
        build: buildSearchBloc,
        seed: () => const CharactersState(
          status: CharactersStatus.failure,
          query: 'rick',
          failure: networkFailure,
        ),
        setUp: () => when(
          () => repository.getCharacters(name: 'rick'),
        ).thenAnswer((_) async => rickFirstPage),
        act: (bloc) => bloc.add(const CharactersQueryChanged('rick')),
        wait: searchSettle,
        expect: () => [rickLoadingState, rickLoadedState],
      );

      blocTest<CharactersBloc, CharactersState>(
        'new query while the previous search is in flight → the stale result is never emitted',
        build: buildSearchBloc,
        setUp: () {
          pendingPage = Completer<CharactersPageEntity>();
          when(() => repository.getCharacters(name: 'rick')).thenAnswer((_) => pendingPage.future);
          when(() => repository.getCharacters(name: 'morty')).thenAnswer((_) async => mortyPage);
        },
        act: (bloc) async {
          bloc.add(const CharactersQueryChanged('rick'));
          await pumpEventQueue();
          bloc.add(const CharactersQueryChanged('morty'));
          await pumpEventQueue();
          pendingPage.complete(rickFirstPage);
        },
        expect: () => [
          rickLoadingState,
          const CharactersState(status: CharactersStatus.loading, query: 'morty'),
          CharactersState(
            status: CharactersStatus.success,
            characters: mortyPage.characters,
            query: 'morty',
          ),
        ],
      );

      blocTest<CharactersBloc, CharactersState>(
        'old query next page in flight → new query pages normally and the stale page is ignored',
        build: buildSearchBloc,
        seed: () => loadedState,
        setUp: () {
          pendingPage = Completer<CharactersPageEntity>();
          when(() => repository.getCharacters(page: 2)).thenAnswer((_) => pendingPage.future);
          when(
            () => repository.getCharacters(name: 'rick'),
          ).thenAnswer((_) async => rickFirstPage);
          when(
            () => repository.getCharacters(page: 2, name: 'rick'),
          ).thenAnswer((_) async => rickSecondPage);
        },
        act: (bloc) async {
          bloc.add(const CharactersNextPageRequested());
          await pumpEventQueue();
          bloc.add(const CharactersQueryChanged('rick'));
          await pumpEventQueue();
          bloc.add(const CharactersNextPageRequested());
          await pumpEventQueue();
          pendingPage.complete(secondPage);
        },
        expect: () => [
          CharactersState(
            status: CharactersStatus.success,
            characters: firstPage.characters,
            nextPage: 2,
            nextPageStatus: NextPageStatus.loading,
          ),
          rickLoadingState,
          rickLoadedState,
          CharactersState(
            status: CharactersStatus.success,
            characters: rickFirstPage.characters,
            query: 'rick',
            nextPage: 2,
            nextPageStatus: NextPageStatus.loading,
          ),
          CharactersState(
            status: CharactersStatus.success,
            characters: [...rickFirstPage.characters, ...rickSecondPage.characters],
            query: 'rick',
            nextPage: 3,
          ),
        ],
        verify: (_) {
          verify(() => repository.getCharacters(page: 2, name: 'rick')).called(1);
        },
      );

      blocTest<CharactersBloc, CharactersState>(
        'next-page retry in flight when a new query arrives → its failure is ignored',
        build: buildSearchBloc,
        seed: () => failedNextPageState,
        setUp: () {
          pendingPage = Completer<CharactersPageEntity>();
          when(() => repository.getCharacters(page: 2)).thenAnswer((_) => pendingPage.future);
          when(
            () => repository.getCharacters(name: 'rick'),
          ).thenAnswer((_) async => rickFirstPage);
        },
        act: (bloc) async {
          bloc.add(const CharactersRetried());
          await pumpEventQueue();
          bloc.add(const CharactersQueryChanged('rick'));
          await pumpEventQueue();
          pendingPage.completeError(networkFailure);
        },
        expect: () => [
          CharactersState(
            status: CharactersStatus.success,
            characters: firstPage.characters,
            nextPage: 2,
            nextPageStatus: NextPageStatus.loading,
          ),
          rickLoadingState,
          rickLoadedState,
        ],
      );

      for (final (outcome, complete) in [
        ('success', (Completer<CharactersPageEntity> c) => c.complete(firstPage)),
        ('failure', (Completer<CharactersPageEntity> c) => c.completeError(networkFailure)),
      ]) {
        blocTest<CharactersBloc, CharactersState>(
          'initial load in flight when a search starts → its late $outcome is never emitted',
          build: buildSearchBloc,
          setUp: () {
            pendingPage = Completer<CharactersPageEntity>();
            when(() => repository.getCharacters()).thenAnswer((_) => pendingPage.future);
            when(
              () => repository.getCharacters(name: 'rick'),
            ).thenAnswer((_) async => rickFirstPage);
          },
          act: (bloc) async {
            bloc.add(const CharactersStarted());
            await pumpEventQueue();
            bloc.add(const CharactersQueryChanged('rick'));
            await pumpEventQueue();
            complete(pendingPage);
          },
          expect: () => [loadingState, rickLoadingState, rickLoadedState],
        );
      }

      for (final (outcome, latest, latestState) in [
        (
          'success',
          () async => secondPage,
          CharactersState(
            status: CharactersStatus.success,
            characters: secondPage.characters,
            nextPage: 3,
          ),
        ),
        ('failure', () async => throw networkFailure, failedFirstPageState),
      ]) {
        blocTest<CharactersBloc, CharactersState>(
          'same query reloaded while its first load is in flight → only the latest $outcome counts',
          build: buildSearchBloc,
          setUp: () {
            pendingPage = Completer<CharactersPageEntity>();
            var calls = 0;
            when(
              () => repository.getCharacters(),
            ).thenAnswer((_) => ++calls == 1 ? pendingPage.future : latest());
          },
          act: (bloc) async {
            bloc.add(const CharactersStarted());
            await pumpEventQueue();
            bloc.add(const CharactersQueryChanged(''));
            await pumpEventQueue();
            pendingPage.complete(firstPage);
          },
          expect: () => [loadingState, latestState],
        );
      }

      blocTest<CharactersBloc, CharactersState>(
        'next page in flight when the same query is reloaded → the stale page is not appended',
        build: buildSearchBloc,
        seed: () => loadedState,
        setUp: () {
          pendingPage = Completer<CharactersPageEntity>();
          when(() => repository.getCharacters(page: 2)).thenAnswer((_) => pendingPage.future);
          when(() => repository.getCharacters()).thenAnswer((_) async => firstPage);
          when(
            () => repository.getCharacters(name: 'rick'),
          ).thenAnswer((_) async => rickFirstPage);
        },
        act: (bloc) async {
          bloc.add(const CharactersNextPageRequested());
          await pumpEventQueue();
          bloc.add(const CharactersQueryChanged('rick'));
          await pumpEventQueue();
          bloc.add(const CharactersQueryChanged(''));
          await pumpEventQueue();
          pendingPage.complete(secondPage);
        },
        expect: () => [
          CharactersState(
            status: CharactersStatus.success,
            characters: firstPage.characters,
            nextPage: 2,
            nextPageStatus: NextPageStatus.loading,
          ),
          rickLoadingState,
          rickLoadedState,
          loadingState,
          loadedState,
        ],
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
