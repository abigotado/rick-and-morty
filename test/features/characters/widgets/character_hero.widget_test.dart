import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/features/characters/widgets/character_hero.dart';
import 'package:rick_and_morty/features/characters/widgets/character_image.dart';

void main() {
  group('CharacterHero', () {
    final url = Uri.parse('https://rickandmortyapi.com/api/character/avatar/1.jpeg');
    const avatarRadius = BorderRadius.all(Radius.circular(14));

    Future<NavigatorState> pumpList(WidgetTester tester, {TargetPlatform? platform}) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          navigatorKey: navigatorKey,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox.square(
                dimension: 68,
                child: CharacterHero(
                  characterId: 1,
                  url: url,
                  borderRadius: avatarRadius,
                  decodeExtent: 68,
                ),
              ),
            ),
          ),
        ),
      );
      return navigatorKey.currentState!;
    }

    Future<void> pushDetails(NavigatorState navigator) async => unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (context) => Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: CharacterHero(characterId: 1, url: url),
              ),
            ),
          ),
        ),
      ),
    );

    CharacterImage shuttle(WidgetTester tester) =>
        tester.widget<CharacterImage>(find.byType(CharacterImage));

    double cornerOf(WidgetTester tester) => shuttle(tester).borderRadius.topLeft.x;

    group('build', () {
      testWidgets('push → corners morph from the avatar radius to square', (tester) async {
        final navigator = await pumpList(tester);

        await pushDetails(navigator);
        await tester.pump();
        await tester.pump();
        final takeoff = cornerOf(tester);
        await tester.pump(const Duration(milliseconds: 150));
        final midway = cornerOf(tester);

        expect(takeoff, moreOrLessEquals(14, epsilon: 0.5));
        expect(midway, inExclusiveRange(0, takeoff));
      });

      testWidgets('pop → corners morph from square back to the avatar radius', (tester) async {
        final navigator = await pumpList(tester);
        await pushDetails(navigator);
        await tester.pumpAndSettle();

        navigator.pop();
        await tester.pump();
        await tester.pump();
        final takeoff = cornerOf(tester);
        await tester.pump(const Duration(milliseconds: 150));
        final midway = cornerOf(tester);

        expect(takeoff, moreOrLessEquals(0, epsilon: 0.5));
        expect(midway, inExclusiveRange(takeoff, 14));
      });

      testWidgets('push → full-size image with the avatar decode as its preview', (tester) async {
        final navigator = await pumpList(tester);

        await pushDetails(navigator);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        expect(shuttle(tester).decodeExtent, isNull);
        expect(shuttle(tester).previewExtent, 68);
      });

      testWidgets('pop → full-size image, not the avatar decode stretched', (tester) async {
        final navigator = await pumpList(tester);
        await pushDetails(navigator);
        await tester.pumpAndSettle();

        navigator.pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        expect(shuttle(tester).decodeExtent, isNull);
        expect(shuttle(tester).previewExtent, 68);
      });

      testWidgets('iOS back swipe → image flies with the gesture', (tester) async {
        final navigator = await pumpList(tester, platform: TargetPlatform.iOS);
        await pushDetails(navigator);
        await tester.pumpAndSettle();

        final gesture = await tester.startGesture(const Offset(5, 400));
        await gesture.moveBy(const Offset(40, 0));
        await gesture.moveBy(const Offset(120, 0));
        await tester.pump();

        expect(find.byType(CharacterImage), findsOneWidget);
        expect(shuttle(tester).previewExtent, 68);
        await gesture.up();
        await tester.pumpAndSettle();
      });
    });
  });
}
