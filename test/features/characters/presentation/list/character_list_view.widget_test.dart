import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty/app/theme.dart';
import 'package:rick_and_morty/core/failure.dart';
import 'package:rick_and_morty/core/failure_message.dart';
import 'package:rick_and_morty/features/characters/domain/character.dart';
import 'package:rick_and_morty/features/characters/presentation/list/bloc/characters_bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/list/character_list_view.dart';
import 'package:rick_and_morty/features/characters/presentation/list/widgets/character_card.dart';
import 'package:rick_and_morty/features/characters/presentation/list/widgets/character_tile.dart';

import '../../../../helpers/character_fixtures.dart';

class MockCharactersBloc extends MockBloc<CharactersEvent, CharactersState>
    implements CharactersBloc {}

void main() {
  late MockCharactersBloc bloc;

  setUp(() {
    bloc = MockCharactersBloc();
  });

  Future<void> pumpView(
    WidgetTester tester,
    CharactersState state, {
    double width = 400,
    Stream<CharactersState> states = const Stream.empty(),
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = Size(width, 800);
    addTearDown(tester.view.reset);
    whenListen(bloc, states, initialState: state);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider<CharactersBloc>.value(
          value: bloc,
          child: const CharacterListView(),
        ),
      ),
    );
  }

  CharactersState successState({
    List<Character>? characters,
    int? nextPage,
    NextPageStatus nextPageStatus = NextPageStatus.idle,
  }) {
    return CharactersState(
      status: CharactersStatus.success,
      characters: characters ?? [buildCharacter(1), buildCharacter(2)],
      nextPage: nextPage,
      nextPageStatus: nextPageStatus,
    );
  }

  group('CharacterListView', () {
    group('loading', () {
      for (final status in [CharactersStatus.initial, CharactersStatus.loading]) {
        testWidgets('${status.name} status → centered progress and no items', (tester) async {
          await pumpView(tester, CharactersState(status: status));

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(find.byType(CharacterTile), findsNothing);
          expect(find.text('Retry'), findsNothing);
        });
      }
    });

    group('failure', () {
      for (final failure in const <Failure>[
        NetworkFailure(),
        ServerFailure(500),
        ServerFailure(429),
      ]) {
        testWidgets('$failure → shows its message', (tester) async {
          await pumpView(
            tester,
            CharactersState(status: CharactersStatus.failure, failure: failure),
          );

          expect(find.text(failure.message), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsNothing);
        });
      }

      testWidgets('failure without details → generic message', (tester) async {
        await pumpView(tester, const CharactersState(status: CharactersStatus.failure));

        expect(find.text('Something went wrong.'), findsOneWidget);
      });

      testWidgets('tap Retry → adds CharactersRetried', (tester) async {
        await pumpView(
          tester,
          const CharactersState(status: CharactersStatus.failure, failure: NetworkFailure()),
        );

        await tester.tap(find.text('Retry'));

        verify(() => bloc.add(const CharactersRetried())).called(1);
      });
    });

    group('success', () {
      testWidgets('empty list → shows the empty message', (tester) async {
        await pumpView(tester, successState(characters: const []));

        expect(find.text('No characters found'), findsOneWidget);
        expect(find.byType(CharacterTile), findsNothing);
        expect(find.text('Retry'), findsNothing);
      });

      testWidgets('characters → names and status labels', (tester) async {
        await pumpView(
          tester,
          successState(
            characters: [
              buildCharacter(1, name: 'Rick Sanchez'),
              buildCharacter(2, name: 'Birdperson', status: CharacterStatus.dead),
              buildCharacter(3, name: 'Abadango Cluster Princess', status: CharacterStatus.unknown),
            ],
          ),
        );

        expect(find.text('Rick Sanchez'), findsOneWidget);
        expect(find.text('Birdperson'), findsOneWidget);
        expect(find.text('Abadango Cluster Princess'), findsOneWidget);
        expect(find.text('Alive'), findsOneWidget);
        expect(find.text('Dead'), findsOneWidget);
        expect(find.text('Unknown'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('no more pages → no footer', (tester) async {
        await pumpView(tester, successState());

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Retry'), findsNothing);
      });

      testWidgets('hasMore → footer progress below the items', (tester) async {
        await pumpView(tester, successState(nextPage: 2));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(CharacterTile), findsNWidgets(2));
      });

      testWidgets('next page loading → footer progress', (tester) async {
        await pumpView(
          tester,
          successState(nextPage: 2, nextPageStatus: NextPageStatus.loading),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Retry'), findsNothing);
      });

      testWidgets('next page failure → items stay and footer Retry adds CharactersRetried', (
        tester,
      ) async {
        await pumpView(
          tester,
          successState(nextPage: 2, nextPageStatus: NextPageStatus.failure),
        );

        expect(find.byType(CharacterTile), findsNWidgets(2));
        expect(find.text("Couldn't load more characters"), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        await tester.tap(find.text('Retry'));

        verify(() => bloc.add(const CharactersRetried())).called(1);
      });
    });

    group('infinite scroll', () {
      testWidgets('scrolling near the end → adds CharactersNextPageRequested', (tester) async {
        await pumpView(
          tester,
          successState(
            characters: List.generate(30, (index) => buildCharacter(index + 1)),
            nextPage: 2,
          ),
        );
        verifyNever(() => bloc.add(const CharactersNextPageRequested()));

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -10000));
        await tester.pump();

        verify(() => bloc.add(const CharactersNextPageRequested())).called(greaterThan(0));
      });

      testWidgets('scrolling a little → does not request the next page', (tester) async {
        await pumpView(
          tester,
          successState(
            characters: List.generate(30, (index) => buildCharacter(index + 1)),
            nextPage: 2,
          ),
        );

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
        await tester.pump();

        verifyNever(() => bloc.add(const CharactersNextPageRequested()));
      });

      testWidgets('first page does not fill the viewport → requests the next page', (
        tester,
      ) async {
        final states = StreamController<CharactersState>();
        addTearDown(states.close);
        await pumpView(
          tester,
          const CharactersState(status: CharactersStatus.loading),
          states: states.stream,
        );
        verifyNever(() => bloc.add(const CharactersNextPageRequested()));

        states.add(successState(nextPage: 2));
        await tester.pump();
        await tester.pump();

        verify(() => bloc.add(const CharactersNextPageRequested())).called(1);
      });

      testWidgets('appended page still does not fill the viewport → requests again', (
        tester,
      ) async {
        final states = StreamController<CharactersState>();
        addTearDown(states.close);
        await pumpView(
          tester,
          successState(nextPage: 2, nextPageStatus: NextPageStatus.loading),
          states: states.stream,
        );
        verifyNever(() => bloc.add(const CharactersNextPageRequested()));

        states.add(
          successState(
            characters: [buildCharacter(1), buildCharacter(2), buildCharacter(3)],
            nextPage: 3,
          ),
        );
        await tester.pump();
        await tester.pump();

        verify(() => bloc.add(const CharactersNextPageRequested())).called(1);
      });

      testWidgets('window grows so items no longer fill it → requests the next page', (
        tester,
      ) async {
        await pumpView(
          tester,
          successState(
            characters: List.generate(30, (index) => buildCharacter(index + 1)),
            nextPage: 2,
          ),
        );
        await tester.pump();
        clearInteractions(bloc);

        tester.view.physicalSize = const Size(2560, 1440);
        await tester.pump();
        await tester.pump();

        verify(() => bloc.add(const CharactersNextPageRequested())).called(greaterThan(0));
      });

      testWidgets('next page failed → does not request on its own', (tester) async {
        final states = StreamController<CharactersState>();
        addTearDown(states.close);
        await pumpView(
          tester,
          successState(nextPage: 2, nextPageStatus: NextPageStatus.loading),
          states: states.stream,
        );
        clearInteractions(bloc);

        states.add(successState(nextPage: 2, nextPageStatus: NextPageStatus.failure));
        await tester.pump();
        await tester.pump();

        verifyNever(() => bloc.add(const CharactersNextPageRequested()));
      });
    });

    group('layout', () {
      testWidgets('wide screen → grid of CharacterCard', (tester) async {
        await pumpView(tester, successState(), width: 900);

        expect(find.byType(SliverGrid), findsOneWidget);
        expect(find.byType(CharacterCard), findsNWidgets(2));
        expect(find.byType(CharacterTile), findsNothing);
      });

      testWidgets('exactly 600 logical px → grid', (tester) async {
        await pumpView(tester, successState(), width: 600);

        expect(find.byType(CharacterCard), findsNWidgets(2));
        expect(find.byType(CharacterTile), findsNothing);
      });

      testWidgets('narrow screen → list of CharacterTile', (tester) async {
        await pumpView(tester, successState(), width: 599);

        expect(find.byType(SliverGrid), findsNothing);
        expect(find.byType(CharacterTile), findsNWidgets(2));
        expect(find.byType(CharacterCard), findsNothing);
      });
    });

    group('accessibility', () {
      testWidgets('tile → read as name and status, not as an image', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpView(tester, successState(characters: [rick]));

        final semantics = tester.getSemantics(find.byType(CharacterTile));

        expect(semantics.label, 'Rick Sanchez\nStatus: Alive');
        expect(semantics.flagsCollection.isImage, isFalse);
        handle.dispose();
      });

      testWidgets('narrow grid card with large text → no overflow', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 3;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await pumpView(
          tester,
          successState(
            characters: [buildCharacter(1, status: CharacterStatus.unknown)],
          ),
          width: 600,
        );

        expect(tester.takeException(), isNull);
      });
    });
  });
}
