import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty/app/theme.dart';
import 'package:rick_and_morty/core/widgets/skeleton.dart';
import 'package:rick_and_morty/features/characters/details/character_details_view.dart';
import 'package:rick_and_morty/features/characters/details/cubit/character_details_cubit.dart';
import 'package:rick_and_morty/features/characters/details/widgets/character_info_tile.dart';
import 'package:rick_and_morty/features/characters/failure_message.dart';
import 'package:rick_and_morty/features/characters/widgets/character_hero.dart';
import 'package:rick_and_morty/features/characters/widgets/character_image.dart';

import '../../../helpers/character_fixtures.dart';
import '../../../helpers/image_cache.dart';

class MockCharacterDetailsCubit extends MockCubit<CharacterDetailsState>
    implements CharacterDetailsCubit {}

void main() {
  late MockCharacterDetailsCubit cubit;

  setUp(() {
    cubit = MockCharacterDetailsCubit();
    when(() => cubit.load()).thenAnswer((_) async {});
  });

  const listMarker = 'List underneath';

  Future<void> pumpView(
    WidgetTester tester,
    CharacterDetailsState state, {
    Size size = const Size(390, 844),
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = size;
    addTearDown(tester.view.reset);
    whenListen(cubit, const Stream<CharacterDetailsState>.empty(), initialState: state);
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        navigatorKey: navigatorKey,
        home: const Scaffold(body: Text(listMarker)),
      ),
    );
    unawaited(
      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (context) => BlocProvider<CharacterDetailsCubit>.value(
            value: cubit,
            child: const CharacterDetailsView(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  CharacterDetailsState successState(CharacterEntity character) =>
      CharacterDetailsLoaded(character);

  CharacterDetailsState failureState(Failure failure) => CharacterDetailsFailed(failure);

  final parasite = CharacterEntity(
    id: 2,
    name: 'Mr. Beauregard',
    status: CharacterStatus.dead,
    species: 'Alien',
    type: 'Parasite',
    gender: 'Male',
    origin: 'unknown',
    location: 'Earth (Replacement Dimension)',
    imageUrl: Uri.parse('https://rickandmortyapi.com/api/character/avatar/2.jpeg'),
  );

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  group('CharacterDetailsView', () {
    group('success', () {
      testWidgets('character → every brief field', (tester) async {
        await pumpView(tester, successState(rick));

        expect(find.text('Rick Sanchez'), findsOneWidget);
        expect(find.text('Alive'), findsOneWidget);
        expect(find.text('Human · Male'), findsOneWidget);
        for (final (label, value) in [
          ('SPECIES', 'Human'),
          ('GENDER', 'Male'),
          ('ORIGIN', 'Earth (C-137)'),
          ('LAST KNOWN LOCATION', 'Citadel of Ricks'),
        ]) {
          final tile = find.ancestor(
            of: find.text(label),
            matching: find.byType(CharacterInfoTile),
          );
          expect(find.descendant(of: tile, matching: find.text(value)), findsOneWidget);
        }
        expect(
          tester.widget<CharacterImage>(find.byType(CharacterImage)).url,
          rick.imageUrl,
        );
      });

      testWidgets('non-empty type → shown between species and gender', (tester) async {
        await pumpView(tester, successState(parasite));

        expect(find.text('Alien · Parasite · Male'), findsOneWidget);
        expect(find.text('Dead'), findsOneWidget);
      });

      testWidgets('empty type → species and gender joined by a single separator', (
        tester,
      ) async {
        const robot = CharacterEntity(
          id: 3,
          name: 'Butter Robot',
          status: CharacterStatus.unknown,
          species: 'Robot',
          type: '',
          gender: 'Genderless',
          origin: 'Earth (C-137)',
          location: 'Earth (C-137)',
          imageUrl: null,
        );
        final handle = tester.ensureSemantics();
        await pumpView(tester, successState(robot));

        expect(find.text('Robot · Genderless'), findsOneWidget);
        expect(find.bySemanticsLabel(RegExp('Robot · Genderless')), findsNothing);
        expect(find.bySemanticsLabel(RegExp('^Type')), findsNothing);
        handle.dispose();
      });

      testWidgets('full image still loading → header shows the cached list avatar', (
        tester,
      ) async {
        final avatar = await seedCachedImage(
          tester,
          rick.imageUrl!,
          cacheWidth: CharacterHero.avatarExtent.toInt(),
        );
        await pumpView(tester, successState(rick));

        final images = tester.widgetList<RawImage>(find.byType(RawImage));
        expect(images.any((image) => image.image?.isCloneOf(avatar) ?? false), isTrue);
      });

      testWidgets('image → hero tagged by id and labelled as a portrait', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpView(tester, successState(rick));

        final hero = tester.widget<Hero>(
          find.ancestor(of: find.byType(CharacterImage), matching: find.byType(Hero)),
        );
        final semantics = tester.getSemantics(find.byType(CharacterImage));

        expect(hero.tag, CharacterHero.heroTag(1));
        expect(semantics.label, 'Portrait of Rick Sanchez');
        expect(semantics.flagsCollection.isImage, isTrue);
        handle.dispose();
      });

      testWidgets('summary line → only the type is announced, tiles announce the rest', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpView(tester, successState(parasite));

        expect(find.bySemanticsLabel(RegExp('Alien · Parasite · Male')), findsNothing);
        expect(find.bySemanticsLabel('Type: Parasite'), findsOneWidget);
        expect(find.bySemanticsLabel('Species: Alien'), findsOneWidget);
        expect(find.bySemanticsLabel('Gender: Male'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('narrow screen with 3x text → no overflow, location reachable', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 3;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await pumpView(tester, successState(parasite), size: const Size(320, 640));
        expect(tester.takeException(), isNull);

        await tester.scrollUntilVisible(
          find.text('Earth (Replacement Dimension)'),
          200,
          scrollable: find.byType(Scrollable),
        );
        expect(find.text('Earth (Replacement Dimension)').hitTestable(), findsOneWidget);
      });

      testWidgets('wide screen → image and tiles capped at 640 and centered', (tester) async {
        await pumpView(tester, successState(rick), size: const Size(1280, 900));

        final image = tester.getRect(find.byType(CharacterImage));
        final origin = tester.getRect(
          find.ancestor(of: find.text('ORIGIN'), matching: find.byType(CharacterInfoTile)),
        );

        expect(image.width, 640);
        expect(image.center.dx, 640);
        expect(image.height, lessThanOrEqualTo(420));
        expect(origin.left, image.left + 20);
        expect(origin.right, image.right - 20);
      });
    });

    group('loading', () {
      testWidgets('no character yet → labelled skeleton and back button', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpView(tester, const CharacterDetailsLoading());

        expect(find.bySemanticsLabel('Loading character'), findsOneWidget);
        expect(find.byType(SkeletonBox), findsWidgets);
        expect(find.byType(CharacterImage), findsNothing);
        expect(find.byTooltip('Back to characters'), findsOneWidget);
        handle.dispose();
      });
    });

    group('failure', () {
      testWidgets('network failure → title, message and Try again reloads', (tester) async {
        const failure = NetworkFailure();
        await pumpView(tester, failureState(failure));

        expect(find.text(failure.title), findsOneWidget);
        expect(find.text(failure.message), findsOneWidget);
        expect(find.byType(OutlinedButton), findsNothing);

        await tester.tap(find.text('Try again'));

        verify(() => cubit.load()).called(1);
      });

      testWidgets('not found → Back to characters pops instead of retrying', (tester) async {
        const failure = NotFoundFailure();
        await pumpView(tester, failureState(failure));

        expect(find.text(failure.title), findsOneWidget);
        expect(find.text('Try again'), findsNothing);

        await tapAndSettle(tester, find.widgetWithText(OutlinedButton, 'Back to characters'));

        expect(find.byType(CharacterDetailsView), findsNothing);
        expect(find.text(listMarker), findsOneWidget);
        verifyNever(() => cubit.load());
      });
    });

    group('back button', () {
      for (final (name, state) in [
        ('success', successState(rick)),
        ('loading', const CharacterDetailsLoading()),
        ('failure', failureState(const ServerFailure(500))),
      ]) {
        testWidgets('$name → pops back to the list', (tester) async {
          await pumpView(tester, state);

          await tapAndSettle(tester, find.byTooltip('Back to characters'));

          expect(find.byType(CharacterDetailsView), findsNothing);
          expect(find.text(listMarker), findsOneWidget);
        });
      }

      Rect backButtonRect(WidgetTester tester) => tester.getRect(
        find.descendant(of: find.byType(IconButton), matching: find.byType(Material)).first,
      );

      testWidgets('safe area → 44 px button 10 below the inset and 16 from the edge', (
        tester,
      ) async {
        tester.view.padding = const FakeViewPadding(top: 47);
        await pumpView(tester, successState(rick));

        expect(backButtonRect(tester), const Rect.fromLTWH(16, 57, 44, 44));
        expect(tester.getSize(find.byType(IconButton)), const Size.square(48));
      });

      for (final (name, size, padding, left) in [
        ('wide screen', const Size(1280, 900), FakeViewPadding.zero, 336.0),
        (
          'landscape inset inside the margin',
          const Size(844, 390),
          const FakeViewPadding(left: 47),
          118.0,
        ),
        (
          'landscape inset beyond the margin',
          const Size(700, 390),
          const FakeViewPadding(left: 47),
          63.0,
        ),
      ]) {
        testWidgets('$name → aligned 16 inside the centred 640 content frame', (tester) async {
          tester.view.padding = padding;
          await pumpView(tester, successState(rick), size: size);

          final image = tester.getRect(find.byType(CharacterImage));

          expect(backButtonRect(tester), Rect.fromLTWH(left, 10, 44, 44));
          expect(image.left, (size.width - 640) / 2);
        });
      }
    });
  });
}
