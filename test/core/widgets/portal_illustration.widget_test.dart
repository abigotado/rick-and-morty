import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/core/widgets/portal_illustration.dart';

void main() {
  group('PortalIllustration', () {
    Future<void> pumpPortal(WidgetTester tester, {bool broken = false}) {
      return tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: PortalIllustration(
              icon: Icons.search_off_rounded,
              color: Colors.green,
              broken: broken,
            ),
          ),
        ),
      );
    }

    double turns(WidgetTester tester) => tester
        .widget<RotationTransition>(
          find.descendant(
            of: find.byType(PortalIllustration),
            matching: find.byType(RotationTransition),
          ),
        )
        .turns
        .value;

    group('build', () {
      testWidgets('appears → plays one settle turn, then stays still', (tester) async {
        await pumpPortal(tester);

        expect(tester.hasRunningAnimations, isTrue);
        expect(turns(tester), isNot(0));

        await tester.pumpAndSettle();

        expect(turns(tester), 0);
        expect(tester.hasRunningAnimations, isFalse);
      });

      testWidgets('broken → still from the first frame', (tester) async {
        await pumpPortal(tester, broken: true);

        expect(tester.hasRunningAnimations, isFalse);
        expect(turns(tester), 0);
      });

      testWidgets('animations disabled → still from the first frame', (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
          disableAnimations: true,
        );
        addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
        await pumpPortal(tester);

        expect(tester.hasRunningAnimations, isFalse);
        expect(turns(tester), 0);
      });

      testWidgets('becomes broken mid-turn → snaps still', (tester) async {
        await pumpPortal(tester);
        await tester.pump(const Duration(milliseconds: 100));

        await pumpPortal(tester, broken: true);

        expect(tester.hasRunningAnimations, isFalse);
        expect(turns(tester), 0);
      });
    });
  });
}
