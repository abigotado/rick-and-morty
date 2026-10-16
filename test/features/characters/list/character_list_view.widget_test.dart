import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty/app/theme.dart';
import 'package:rick_and_morty/core/widgets/collapsing_header.dart';
import 'package:rick_and_morty/core/widgets/entrance.dart';
import 'package:rick_and_morty/core/widgets/highlighted_text.dart';
import 'package:rick_and_morty/core/widgets/skeleton.dart';
import 'package:rick_and_morty/features/characters/failure_message.dart';
import 'package:rick_and_morty/features/characters/list/bloc/characters_bloc.dart';
import 'package:rick_and_morty/features/characters/list/character_list_view.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_card.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_tile.dart';

import '../../../helpers/character_fixtures.dart';

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
        theme: AppTheme.dark,
        home: BlocProvider<CharactersBloc>.value(
          value: bloc,
          child: const CharacterListView(),
        ),
      ),
    );
  }

  CharactersState successState({
    List<CharacterEntity>? characters,
    int? nextPage,
    NextPageStatus nextPageStatus = NextPageStatus.idle,
    String query = '',
    int totalCount = 0,
  }) {
    return CharactersState(
      status: CharactersStatus.success,
      characters: characters ?? [buildCharacter(1), buildCharacter(2)],
      query: query,
      totalCount: totalCount,
      nextPage: nextPage,
      nextPageStatus: nextPageStatus,
    );
  }

  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  group('CharacterListView', () {
    group('header caption', () {
      final cases = <String, CharactersState>{
        'Opening a portal…': const CharactersState(),
        '826 across the multiverse': successState(totalCount: 826),
        'No matches': successState(characters: const [], query: 'zzz'),
        '1 match': successState(characters: [rick], query: 'rick sanchez', totalCount: 1),
        '107 matches': successState(query: 'rick', totalCount: 107),
      };
      for (final MapEntry(key: caption, value: state) in cases.entries) {
        testWidgets('${state.status.name} "${state.query}" → "$caption"', (tester) async {
          await pumpView(tester, state);

          expect(
            find.descendant(of: find.byType(CollapsingHeader), matching: find.text(caption)),
            findsOneWidget,
          );
        });
      }

      testWidgets('failure → no caption', (tester) async {
        await pumpView(
          tester,
          const CharactersState(status: CharactersStatus.failure, failure: NetworkFailure()),
        );

        expect(
          find.descendant(
            of: find.byType(CollapsingHeader),
            matching: find.textContaining(RegExp('portal|multiverse|match')),
          ),
          findsNothing,
        );
      });

      testWidgets('first page arrives → caption switches from loading to the count', (
        tester,
      ) async {
        final states = StreamController<CharactersState>();
        addTearDown(states.close);
        await pumpView(
          tester,
          const CharactersState(status: CharactersStatus.loading),
          states: states.stream,
        );

        states.add(successState(totalCount: 826));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('826 across the multiverse'), findsOneWidget);
        expect(find.text('Opening a portal…'), findsNothing);
      });
    });

    group('loading', () {
      for (final status in [CharactersStatus.initial, CharactersStatus.loading]) {
        testWidgets('${status.name} status → labelled skeleton and no items', (tester) async {
          final handle = tester.ensureSemantics();
          await pumpView(tester, CharactersState(status: status));

          expect(find.bySemanticsLabel('Loading characters'), findsOneWidget);
          expect(find.byType(SkeletonBox), findsWidgets);
          expect(find.byType(CharacterTile), findsNothing);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.text('Try again'), findsNothing);
          handle.dispose();
        });
      }
    });

    group('failure', () {
      for (final failure in const <Failure>[
        NetworkFailure(),
        ServerFailure(500),
        ServerFailure(429),
      ]) {
        testWidgets('$failure → shows its title and message', (tester) async {
          await pumpView(
            tester,
            CharactersState(status: CharactersStatus.failure, failure: failure),
          );

          expect(find.text(failure.title), findsOneWidget);
          expect(find.text(failure.message), findsOneWidget);
          expect(find.byType(SkeletonBox), findsNothing);
          expect(find.byType(CharacterTile), findsNothing);
        });
      }

      testWidgets('failure without details → generic title', (tester) async {
        await pumpView(tester, const CharactersState(status: CharactersStatus.failure));

        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);
      });

      testWidgets('tap Try again → adds CharactersRetried', (tester) async {
        await pumpView(
          tester,
          const CharactersState(status: CharactersStatus.failure, failure: NetworkFailure()),
        );
        await tester.pump(const Duration(milliseconds: 200));

        await tester.tap(find.widgetWithText(FilledButton, 'Try again'));

        verify(() => bloc.add(const CharactersRetried())).called(1);
      });
    });

    group('success', () {
      testWidgets('empty list → shows the empty message', (tester) async {
        await pumpView(tester, successState(characters: const []));

        expect(find.text('No characters found'), findsOneWidget);
        expect(find.byType(CharacterTile), findsNothing);
        expect(find.text('Clear search'), findsNothing);
        expect(find.text('Try again'), findsNothing);
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

      testWidgets('first page arrives → items fade in from transparent to opaque', (
        tester,
      ) async {
        final states = StreamController<CharactersState>();
        addTearDown(states.close);
        await pumpView(
          tester,
          const CharactersState(status: CharactersStatus.loading),
          states: states.stream,
        );

        states.add(successState());
        await tester.pump();
        await tester.pump();

        double firstItemOpacity() => tester
            .widget<Opacity>(
              find
                  .descendant(of: find.byType(StaggeredEntrance), matching: find.byType(Opacity))
                  .first,
            )
            .opacity;
        expect(firstItemOpacity(), lessThan(1));

        await tester.pump(StaggeredEntrance.totalDuration);

        expect(firstItemOpacity(), 1);
      });

      testWidgets('first page arrives with animations disabled → items opaque at once', (
        tester,
      ) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
          disableAnimations: true,
        );
        addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
        final states = StreamController<CharactersState>();
        addTearDown(states.close);
        await pumpView(
          tester,
          const CharactersState(status: CharactersStatus.loading),
          states: states.stream,
        );

        states.add(successState());
        await tester.pump();
        await tester.pump();

        final opacities = tester.widgetList<Opacity>(
          find.descendant(of: find.byType(StaggeredEntrance), matching: find.byType(Opacity)),
        );
        expect(opacities.map((opacity) => opacity.opacity), everyElement(1));
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

    group('search', () {
      testWidgets('state with a query → search bar prefilled with it', (tester) async {
        await pumpView(tester, successState(query: 'rick'));

        expect(fieldText(tester), 'rick');
      });

      testWidgets('typing → adds CharactersQueryChanged with the text', (tester) async {
        await pumpView(tester, successState());

        await tester.enterText(find.byType(TextField), 'morty');

        verify(() => bloc.add(const CharactersQueryChanged('morty'))).called(1);
      });

      testWidgets('empty result for a query → names the query and offers to clear it', (
        tester,
      ) async {
        await pumpView(tester, successState(characters: const [], query: 'rick'));

        expect(find.text('No one by that name'), findsOneWidget);
        expect(find.textContaining('“rick”'), findsOneWidget);
        expect(find.widgetWithText(OutlinedButton, 'Clear search'), findsOneWidget);
        expect(find.text('No characters found'), findsNothing);
      });

      testWidgets('tap Clear search → field emptied and CharactersQueryChanged("") added', (
        tester,
      ) async {
        await pumpView(tester, successState(characters: const [], query: 'rick'));
        await tester.pump(const Duration(milliseconds: 200));
        expect(fieldText(tester), 'rick');

        await tester.tap(find.widgetWithText(OutlinedButton, 'Clear search'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(fieldText(tester), isEmpty);
        expect(find.byTooltip('Clear'), findsNothing);
        verify(() => bloc.add(const CharactersQueryChanged(''))).called(1);
      });

      testWidgets('items for a query → each name highlights the query', (tester) async {
        await pumpView(tester, successState(characters: [rick], query: 'sanch'));

        final name = tester.widget<HighlightedText>(find.byType(HighlightedText));
        expect(name.text, 'Rick Sanchez');
        expect(name.highlight, 'sanch');
      });

      testWidgets('query changes → list jumps back to the top', (tester) async {
        final states = StreamController<CharactersState>();
        addTearDown(states.close);
        final characters = List.generate(30, (index) => buildCharacter(index + 1));
        await pumpView(tester, successState(characters: characters), states: states.stream);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
        await tester.pump();
        final controller = tester
            .widget<CustomScrollView>(find.byType(CustomScrollView))
            .controller!;
        expect(controller.offset, greaterThan(0));

        states.add(successState(characters: characters, query: 'rick'));
        await tester.pump();

        expect(controller.offset, 0);
      });

      testWidgets('new items for the same query → scroll position kept', (tester) async {
        final states = StreamController<CharactersState>();
        addTearDown(states.close);
        final characters = List.generate(30, (index) => buildCharacter(index + 1));
        await pumpView(tester, successState(characters: characters), states: states.stream);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
        await tester.pump();
        final controller = tester
            .widget<CustomScrollView>(find.byType(CustomScrollView))
            .controller!;
        final offset = controller.offset;

        states.add(successState(characters: [...characters, buildCharacter(31)]));
        await tester.pump();

        expect(controller.offset, offset);
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

        // Skeleton → short list fires both the post-frame check and a metrics change; the bloc
        // drops the duplicate (see the bloc's "requested twice while loading" test).
        verify(() => bloc.add(const CharactersNextPageRequested())).called(greaterThan(0));
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

      for (final (name, state, firstItem) in [
        ('items', successState(), find.byType(CharacterCard)),
        (
          'skeleton',
          const CharactersState(status: CharactersStatus.loading),
          find.byType(SkeletonBox),
        ),
      ]) {
        testWidgets('landscape with side insets → header and $name clear the notch', (
          tester,
        ) async {
          await pumpView(tester, state, width: 852);
          tester.view.padding = const FakeViewPadding(left: 59, right: 59);
          await tester.pump();

          const contentLeft = 59 + 16.0;
          expect(tester.getRect(find.text('Characters')).left, contentLeft);
          expect(tester.getRect(find.byType(SearchBar)).left, contentLeft);
          expect(tester.getRect(firstItem.first).left, contentLeft);
        });
      }
    });

    group('accessibility', () {
      testWidgets('tile → one button read as name, status and species, not as an image', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpView(tester, successState(characters: [rick]));

        final semantics = tester.getSemantics(find.byType(CharacterTile));

        expect(semantics.label, 'Rick Sanchez\nStatus: Alive\nHuman');
        expect(semantics.flagsCollection.isImage, isFalse);
        expect(semantics.flagsCollection.isButton, isTrue);
        expect(semantics.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
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
