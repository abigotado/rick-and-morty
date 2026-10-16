import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/core/widgets/pressable_surface.dart';

void main() {
  group('PressableSurface', () {
    Future<void> pumpSurface(WidgetTester tester, {VoidCallback? onTap}) {
      return tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: PressableSurface(
              onTap: onTap,
              child: const SizedBox(width: 200, height: 80, child: Text('Rick')),
            ),
          ),
        ),
      );
    }

    double scale(WidgetTester tester) =>
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

    group('build', () {
      testWidgets('pressed with onTap → shrinks, released → back to full size and tapped', (
        tester,
      ) async {
        var taps = 0;
        await pumpSurface(tester, onTap: () => taps++);

        final gesture = await tester.startGesture(tester.getCenter(find.text('Rick')));
        await tester.pump(kPressTimeout);

        expect(scale(tester), 0.98);

        await gesture.up();
        await tester.pumpAndSettle();

        expect(scale(tester), 1);
        expect(taps, 1);
      });

      testWidgets('pressed without onTap → stays at full size', (tester) async {
        await pumpSurface(tester);

        final gesture = await tester.startGesture(tester.getCenter(find.text('Rick')));
        await tester.pump(kPressTimeout);

        expect(scale(tester), 1);

        await gesture.up();
      });

      testWidgets('hovered with onTap → lifts', (tester) async {
        await pumpSurface(tester, onTap: () {});
        final resting = tester.getTopLeft(find.text('Rick')).dy;
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);

        await mouse.moveTo(tester.getCenter(find.text('Rick')));
        await tester.pumpAndSettle();

        expect(tester.getTopLeft(find.text('Rick')).dy, lessThan(resting));
      });

      testWidgets('with onTap → ink layer covers the surface above the child', (tester) async {
        await pumpSurface(tester, onTap: () {});

        final inkWell = find.byType(InkWell);
        expect(find.ancestor(of: find.text('Rick'), matching: inkWell), findsNothing);
        expect(tester.getRect(inkWell), tester.getRect(find.byType(Stack)));
        final targets = tester
            .hitTestOnBinding(tester.getCenter(find.text('Rick')))
            .path
            .map((entry) => entry.target);
        expect(targets, contains(tester.renderObject(inkWell)));
        expect(targets, isNot(contains(tester.renderObject(find.text('Rick')))));
      });

      testWidgets('pressed over opaque content → splash painted on the ink layer', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: PressableSurface(
                onTap: () {},
                child: const ColoredBox(
                  key: Key('image'),
                  color: Color(0xFF00FF00),
                  child: SizedBox(width: 200, height: 120),
                ),
              ),
            ),
          ),
        );

        final inkLayer = tester.renderObject(
          find.descendant(of: find.byType(Positioned), matching: find.byType(Material)),
        );
        expect(inkLayer, paintsNothing);

        final gesture = await tester.startGesture(tester.getCenter(find.byKey(const Key('image'))));
        await tester.pump(const Duration(milliseconds: 200));

        expect(inkLayer, isNot(paintsNothing));
        await gesture.up();
        await tester.pumpAndSettle();
      });

      testWidgets('hovered without onTap → stays in place', (tester) async {
        await pumpSurface(tester);
        final resting = tester.getTopLeft(find.text('Rick')).dy;
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);

        await mouse.moveTo(tester.getCenter(find.text('Rick')));
        await tester.pumpAndSettle();

        expect(tester.getTopLeft(find.text('Rick')).dy, resting);
      });
    });

    group('semantics', () {
      testWidgets('with onTap → one button node labelled by the child, tap action calls onTap', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        var taps = 0;
        await pumpSurface(tester, onTap: () => taps++);

        final node = tester.getSemantics(find.byType(PressableSurface));
        expect(node.label, 'Rick');
        expect(node.flagsCollection.isButton, isTrue);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        expect(find.bySemanticsLabel('Rick'), findsOneWidget);

        tester.semantics.tap(find.semantics.byLabel('Rick'));
        await tester.pump();

        expect(taps, 1);
        handle.dispose();
      });

      testWidgets('without onTap → not a button and no tap action', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpSurface(tester);

        final node = tester.getSemantics(find.byType(PressableSurface));
        expect(node.label, 'Rick');
        expect(node.flagsCollection.isButton, isFalse);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
        handle.dispose();
      });
    });
  });
}
