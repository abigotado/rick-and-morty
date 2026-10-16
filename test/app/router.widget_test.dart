import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty/app/router.dart';
import 'package:rick_and_morty/app/theme.dart';
import 'package:rick_and_morty/features/characters/details/character_details_page.dart';
import 'package:rick_and_morty/features/characters/list/bloc/characters_bloc.dart';
import 'package:rick_and_morty/features/characters/list/character_list_view.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_card.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_tile.dart';
import 'package:rick_and_morty/features/characters/widgets/character_hero.dart';

import '../helpers/character_fixtures.dart';
import '../helpers/image_cache.dart';

class _MockCharactersRepository extends Mock implements ICharactersRepository {}

void main() {
  late _MockCharactersRepository repository;
  final characters = [rick, for (var id = 2; id <= 20; id++) buildCharacter(id)];

  setUp(() {
    repository = _MockCharactersRepository();
    when(
      () => repository.getCharacters(name: any(named: 'name')),
    ).thenAnswer(
      (_) async => CharactersPageEntity(characters: characters, totalCount: 40, nextPage: 2),
    );
    when(
      () => repository.getCharacters(page: 2, name: any(named: 'name')),
    ).thenAnswer(
      (_) async => CharactersPageEntity(
        characters: [for (var id = 21; id <= 40; id++) buildCharacter(id)],
        totalCount: 40,
      ),
    );
    for (final character in characters) {
      when(() => repository.getCharacter(character.id)).thenAnswer((_) async => character);
    }
  });

  // The footer spinner never settles while another page is available.
  Future<void> settle(WidgetTester tester) async {
    for (var frame = 0; frame < 10; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<GoRouter> pumpApp(WidgetTester tester, {double width = 400, String? location}) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = Size(width, 800);
    addTearDown(tester.view.reset);
    final router = createRouter();
    addTearDown(router.dispose);
    if (location != null) router.go(location);
    await tester.pumpWidget(
      RepositoryProvider<ICharactersRepository>.value(
        value: repository,
        child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
      ),
    );
    await settle(tester);
    return router;
  }

  String locationOf(GoRouter router) => router.routerDelegate.currentConfiguration.uri.toString();

  Future<void> tapBack(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Back to characters'));
    await settle(tester);
  }

  CharacterDetailsPage detailsPage(WidgetTester tester) =>
      tester.widget<CharacterDetailsPage>(find.byType(CharacterDetailsPage));

  group('createRouter', () {
    group('/', () {
      testWidgets('tap a tile → details of that character from the list, no refetch', (
        tester,
      ) async {
        final router = await pumpApp(tester);

        await tester.tap(find.widgetWithText(CharacterTile, 'Character 3'));
        await settle(tester);

        expect(locationOf(router), '/character/3');
        expect(detailsPage(tester).character, characters[2]);
        expect(find.text('Character 3'), findsOneWidget);
        expect(find.byType(CharacterListView), findsNothing);
        verifyNever(() => repository.getCharacter(any()));
      });

      testWidgets('tap a tile → its image is a hero on both routes', (tester) async {
        await pumpApp(tester);

        await tester.tap(find.widgetWithText(CharacterTile, 'Character 3'));
        await tester.pump();
        await tester.pump();

        expect(
          find.byWidgetPredicate(
            (widget) => widget is Hero && widget.tag == CharacterHero.heroTag(3),
            skipOffstage: false,
          ),
          findsNWidgets(2),
        );
      });

      testWidgets('tap a tile, mid-flight → the avatar already in memory, not a placeholder', (
        tester,
      ) async {
        final avatar = await seedCachedImage(
          tester,
          characters[2].imageUrl!,
          cacheWidth: CharacterTile.imageSize.toInt(),
        );
        await pumpApp(tester);
        await tester.tap(find.widgetWithText(CharacterTile, 'Character 3'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        final shown = tester.widget<RawImage>(find.byType(RawImage)).image;
        expect(shown!.isCloneOf(avatar), isTrue);
      });

      testWidgets('tap a card on a wide screen → details of that character', (tester) async {
        final router = await pumpApp(tester, width: 900);

        await tester.tap(find.widgetWithText(CharacterCard, 'Character 2'));
        await settle(tester);

        expect(locationOf(router), '/character/2');
        expect(find.text('Character 2'), findsOneWidget);
        verifyNever(() => repository.getCharacter(any()));
      });

      testWidgets('back from details → same list with its items, query and scroll offset', (
        tester,
      ) async {
        final router = await pumpApp(tester);
        await tester.enterText(find.byType(TextField), 'char');
        await tester.pump(const Duration(milliseconds: 500));
        await settle(tester);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
        await settle(tester);
        final listState = tester.state(find.byType(CharacterListView));
        final bloc = tester.element(find.byType(CharacterListView)).read<CharactersBloc>();
        final controller = tester
            .widget<CustomScrollView>(find.byType(CustomScrollView))
            .controller!;
        final offset = controller.offset;
        expect(offset, greaterThan(0));
        final tile = find.byType(CharacterTile).hitTestable().first;
        final tapped = tester.widget<CharacterTile>(tile).character;
        clearInteractions(repository);

        await tester.tap(tile);
        await settle(tester);
        expect(find.text(tapped.name), findsOneWidget);
        await tapBack(tester);

        expect(locationOf(router), '/');
        expect(tester.state(find.byType(CharacterListView)), same(listState));
        expect(tester.element(find.byType(CharacterListView)).read<CharactersBloc>(), same(bloc));
        expect(bloc.state.query, 'char');
        expect(bloc.state.characters, characters);
        expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'char');
        expect(controller.offset, offset);
        expect(find.byType(CharacterTile), findsWidgets);
        verifyZeroInteractions(repository);
      });

      testWidgets('tap a tile while searching → field unfocused and stays so after back', (
        tester,
      ) async {
        await pumpApp(tester);
        await tester.tap(find.byType(TextField));
        await tester.pump();
        FocusNode searchFocus() =>
            tester.widget<EditableText>(find.byType(EditableText, skipOffstage: false)).focusNode;
        expect(searchFocus().hasFocus, isTrue);

        await tester.tap(find.widgetWithText(CharacterTile, 'Rick Sanchez'));
        await settle(tester);
        expect(searchFocus().hasFocus, isFalse);

        await tapBack(tester);

        expect(searchFocus().hasFocus, isFalse);
        expect(tester.testTextInput.isVisible, isFalse);
      });

      testWidgets('tile opened from the keyboard → focus returns to it after back', (tester) async {
        await pumpApp(tester);
        bool tileFocused() =>
            FocusManager.instance.primaryFocus?.context
                ?.findAncestorWidgetOfExactType<CharacterTile>()
                ?.character
                .name ==
            'Rick Sanchez';
        for (var press = 0; press < 6 && !tileFocused(); press++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
        }
        expect(tileFocused(), isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await settle(tester);
        expect(find.byType(CharacterDetailsPage), findsOneWidget);

        await tapBack(tester);

        expect(tileFocused(), isTrue);
      });
    });

    group('/character/:id', () {
      testWidgets('another id while details are open → that character is shown', (tester) async {
        final router = await pumpApp(tester, location: '/character/1');

        router.go('/character/2');
        await settle(tester);

        expect(locationOf(router), '/character/2');
        expect(detailsPage(tester).characterId, 2);
        expect(find.text(characters[1].name), findsOneWidget);
        expect(find.text('Rick Sanchez'), findsNothing);
        verify(() => repository.getCharacter(2)).called(1);
      });

      testWidgets('deep link without extra → loads by id, back goes to the list', (
        tester,
      ) async {
        final router = await pumpApp(tester, location: '/character/1');

        expect(tester.takeException(), isNull);
        expect(locationOf(router), '/character/1');
        expect(detailsPage(tester).character, isNull);
        expect(find.text('Rick Sanchez'), findsOneWidget);
        verify(() => repository.getCharacter(1)).called(1);

        await tapBack(tester);

        expect(tester.takeException(), isNull);
        expect(locationOf(router), '/');
        expect(find.byType(CharacterListView), findsOneWidget);
        expect(find.widgetWithText(CharacterTile, 'Rick Sanchez'), findsOneWidget);
      });

      testWidgets('extra of another character → ignored, loads by id', (tester) async {
        final router = await pumpApp(tester);

        router.go('/character/2', extra: rick);
        await settle(tester);

        expect(detailsPage(tester).character, isNull);
        expect(find.text('Character 2'), findsOneWidget);
        verify(() => repository.getCharacter(2)).called(1);
      });

      for (final (segment, id) in [('+1', 1), ('007', 7), ('%2B2', 2)]) {
        testWidgets('non-canonical id "$segment" → redirected to /character/$id', (tester) async {
          final router = await pumpApp(tester, location: '/character/$segment');

          expect(locationOf(router), '/character/$id');
          expect(find.text(characters[id - 1].name), findsOneWidget);
          verify(() => repository.getCharacter(id)).called(1);
        });
      }

      for (final id in ['abc', '0', '-3', '1.5', '0x1', '-0', '99999999999999999999']) {
        testWidgets('invalid id "$id" → redirected to the list', (tester) async {
          final router = await pumpApp(tester, location: '/character/$id');

          expect(locationOf(router), '/');
          expect(find.byType(CharacterListView), findsOneWidget);
          expect(find.byType(CharacterDetailsPage, skipOffstage: false), findsNothing);
          verifyNever(() => repository.getCharacter(any()));
        });
      }

      for (final location in ['/character', '/unknown/page']) {
        testWidgets('unknown location "$location" → redirected to the list', (tester) async {
          final router = await pumpApp(tester, location: location);
          await tester.pump();

          expect(locationOf(router), '/');
          expect(find.byType(CharacterListView), findsOneWidget);
        });
      }
    });
  });
}
