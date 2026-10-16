import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/core/widgets/entrance.dart';

void main() {
  group('StaggeredEntrance', () {
    late AnimationController animation;

    setUp(() {
      animation = AnimationController(vsync: const TestVSync());
    });

    tearDown(() {
      animation.dispose();
    });

    Future<void> pumpItems(WidgetTester tester, List<int> indexes) {
      return tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              for (final index in indexes)
                StaggeredEntrance(
                  key: ValueKey(index),
                  animation: animation,
                  index: index,
                  child: const SizedBox.square(dimension: 10),
                ),
            ],
          ),
        ),
      );
    }

    double opacityOf(WidgetTester tester, int index) => tester
        .widget<Opacity>(
          find.descendant(of: find.byKey(ValueKey(index)), matching: find.byType(Opacity)),
        )
        .opacity;

    group('build', () {
      testWidgets('animation at 0 → transparent', (tester) async {
        await pumpItems(tester, [0]);

        expect(opacityOf(tester, 0), 0);
      });

      testWidgets('animation at 1 → every item fully opaque', (tester) async {
        animation.value = 1;
        await pumpItems(tester, [0, 7, 30]);

        expect(opacityOf(tester, 0), 1);
        expect(opacityOf(tester, 7), 1);
        expect(opacityOf(tester, 30), 1);
      });

      testWidgets('mid-animation → later items lag behind earlier ones', (tester) async {
        animation.value = 0.4;
        await pumpItems(tester, [0, 3]);

        expect(opacityOf(tester, 0), greaterThan(opacityOf(tester, 3)));
      });

      testWidgets('index beyond the cap → shares the last slot instead of waiting longer', (
        tester,
      ) async {
        animation.value = 0.75;
        await pumpItems(tester, [7, 30]);

        expect(opacityOf(tester, 7), greaterThan(0));
        expect(opacityOf(tester, 30), opacityOf(tester, 7));
      });
    });
  });

  group('FadeIn', () {
    Future<void> pumpFadeIn(WidgetTester tester) {
      return tester.pumpWidget(
        const MaterialApp(home: FadeIn(child: Text('Hello'))),
      );
    }

    double opacity(WidgetTester tester) => tester
        .widget<Opacity>(
          find.ancestor(of: find.text('Hello'), matching: find.byType(Opacity)),
        )
        .opacity;

    group('build', () {
      testWidgets('first frame → transparent, then fully opaque', (tester) async {
        await pumpFadeIn(tester);

        expect(opacity(tester), 0);

        await tester.pumpAndSettle();

        expect(opacity(tester), 1);
      });

      testWidgets('animations disabled → opaque after the first frame', (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
          disableAnimations: true,
        );
        addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
        await pumpFadeIn(tester);
        await tester.pump();

        expect(opacity(tester), 1);
        expect(tester.hasRunningAnimations, isFalse);
      });
    });
  });
}
