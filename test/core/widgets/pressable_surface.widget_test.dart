import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
  });
}
