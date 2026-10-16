import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/core/widgets/skeleton.dart';

void main() {
  group('Shimmer', () {
    Future<void> pumpShimmer(WidgetTester tester) {
      return tester.pumpWidget(
        const MaterialApp(
          home: Shimmer(child: SkeletonBox(width: 100, height: 20)),
        ),
      );
    }

    group('build', () {
      testWidgets('animations enabled → keeps shimmering', (tester) async {
        await pumpShimmer(tester);
        await tester.pump(const Duration(seconds: 5));

        expect(tester.hasRunningAnimations, isTrue);
      });

      testWidgets('animations disabled → no ticker left running', (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
          disableAnimations: true,
        );
        addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
        await pumpShimmer(tester);

        expect(await tester.pumpAndSettle(), 1);
        expect(tester.hasRunningAnimations, isFalse);
      });

      testWidgets('animations disabled while shimmering → stops', (tester) async {
        await pumpShimmer(tester);
        expect(tester.hasRunningAnimations, isTrue);

        tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
          disableAnimations: true,
        );
        addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
        await tester.pump();

        expect(tester.hasRunningAnimations, isFalse);
      });
    });
  });

  group('SkeletonBox', () {
    group('build', () {
      testWidgets('given size → laid out at that size', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Center(child: SkeletonBox(width: 92, height: 20)),
          ),
        );

        expect(tester.getSize(find.byType(SkeletonBox)), const Size(92, 20));
      });
    });
  });
}
