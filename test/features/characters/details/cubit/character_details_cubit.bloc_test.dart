import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:characters_domain/characters_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty/features/characters/details/cubit/character_details_cubit.dart';

import '../../../../helpers/character_fixtures.dart';

class MockCharactersRepository extends Mock implements ICharactersRepository {}

void main() {
  late MockCharactersRepository repository;
  late Completer<CharacterEntity> pendingCharacter;

  const characterId = 7;
  final character = buildCharacter(characterId);

  const loadingState = CharacterDetailsLoading();
  final loadedState = CharacterDetailsLoaded(character);
  const notFoundFailure = NotFoundFailure();
  const networkFailure = NetworkFailure();

  setUp(() {
    repository = MockCharactersRepository();
  });

  CharacterDetailsCubit buildCubit({CharacterEntity? initialCharacter}) => CharacterDetailsCubit(
    charactersRepository: repository,
    characterId: characterId,
    initialCharacter: initialCharacter,
  );

  group('CharacterDetailsCubit', () {
    test('initial character given → initial state is loaded with that character', () {
      final cubit = buildCubit(initialCharacter: character);
      addTearDown(cubit.close);

      expect(cubit.state, loadedState);
    });

    test('no initial character → initial state is loading', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      expect(cubit.state, loadingState);
    });

    group('load', () {
      blocTest<CharacterDetailsCubit, CharacterDetailsState>(
        'initial character given → no request and no new state',
        build: () => buildCubit(initialCharacter: character),
        act: (cubit) => cubit.load(),
        expect: () => <CharacterDetailsState>[],
        verify: (_) {
          verifyNever(() => repository.getCharacter(any()));
        },
      );

      blocTest<CharacterDetailsCubit, CharacterDetailsState>(
        'request succeeds → loading then loaded with the character fetched by id',
        build: buildCubit,
        setUp: () => when(
          () => repository.getCharacter(characterId),
        ).thenAnswer((_) async => character),
        act: (cubit) => cubit.load(),
        expect: () => [loadingState, loadedState],
        verify: (_) {
          verify(() => repository.getCharacter(characterId)).called(1);
        },
      );

      for (final failure in <Failure>[notFoundFailure, networkFailure]) {
        blocTest<CharacterDetailsCubit, CharacterDetailsState>(
          '${failure.runtimeType} → loading then failed carrying the failure',
          build: buildCubit,
          setUp: () => when(() => repository.getCharacter(characterId)).thenThrow(failure),
          act: (cubit) => cubit.load(),
          expect: () => [
            loadingState,
            CharacterDetailsFailed(failure),
          ],
        );
      }

      blocTest<CharacterDetailsCubit, CharacterDetailsState>(
        'called again after a failure → loading then loaded',
        build: buildCubit,
        setUp: () {
          var calls = 0;
          when(() => repository.getCharacter(characterId)).thenAnswer(
            (_) async => ++calls == 1 ? throw networkFailure : character,
          );
        },
        act: (cubit) async {
          await cubit.load();
          await cubit.load();
        },
        expect: () => [
          loadingState,
          const CharacterDetailsFailed(networkFailure),
          loadingState,
          loadedState,
        ],
        verify: (_) {
          verify(() => repository.getCharacter(characterId)).called(2);
        },
      );

      blocTest<CharacterDetailsCubit, CharacterDetailsState>(
        'called again after loading succeeded → no second request',
        build: buildCubit,
        setUp: () => when(
          () => repository.getCharacter(characterId),
        ).thenAnswer((_) async => character),
        act: (cubit) async {
          await cubit.load();
          await cubit.load();
        },
        expect: () => [loadingState, loadedState],
        verify: (_) {
          verify(() => repository.getCharacter(characterId)).called(1);
        },
      );

      blocTest<CharacterDetailsCubit, CharacterDetailsState>(
        'called twice while the request is in flight → repository called once',
        build: buildCubit,
        setUp: () {
          pendingCharacter = Completer<CharacterEntity>();
          when(
            () => repository.getCharacter(characterId),
          ).thenAnswer((_) => pendingCharacter.future);
        },
        act: (cubit) async {
          final first = cubit.load();
          final second = cubit.load();
          pendingCharacter.complete(character);
          await Future.wait([first, second]);
        },
        expect: () => [loadingState, loadedState],
        verify: (_) {
          verify(() => repository.getCharacter(characterId)).called(1);
        },
      );

      for (final (outcome, complete) in [
        ('success', (Completer<CharacterEntity> c) => c.complete(character)),
        ('failure', (Completer<CharacterEntity> c) => c.completeError(networkFailure)),
      ]) {
        test(
          'closed while the request is in flight → late $outcome is not emitted and no error',
          () async {
            pendingCharacter = Completer<CharacterEntity>();
            when(
              () => repository.getCharacter(characterId),
            ).thenAnswer((_) => pendingCharacter.future);
            final cubit = buildCubit();
            final states = <CharacterDetailsState>[];
            final subscription = cubit.stream.listen(states.add);

            final load = cubit.load();
            await cubit.close();
            complete(pendingCharacter);

            await expectLater(load, completes);
            await subscription.cancel();
            expect(states, [loadingState]);
            expect(cubit.state, loadingState);
          },
        );
      }
    });
  });
}
