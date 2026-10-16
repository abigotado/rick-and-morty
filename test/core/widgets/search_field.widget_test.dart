import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/core/widgets/search_field.dart';

void main() {
  late List<String> changes;

  setUp(() {
    changes = [];
  });

  Future<void> pumpField(
    WidgetTester tester, {
    String initialValue = '',
    TextEditingController? controller,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchField(
            controller: controller,
            initialValue: initialValue,
            onChanged: changes.add,
          ),
        ),
      ),
    );
  }

  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  group('SearchField', () {
    testWidgets('typing → reports the text', (tester) async {
      await pumpField(tester);

      await tester.enterText(find.byType(TextField), 'rick');

      expect(changes, ['rick']);
    });

    testWidgets('empty → no clear button until text is entered', (tester) async {
      await pumpField(tester);

      expect(find.byTooltip('Clear'), findsNothing);

      await tester.enterText(find.byType(TextField), 'rick');
      await tester.pump();

      expect(find.byTooltip('Clear'), findsOneWidget);
    });

    testWidgets('initialValue → field prefilled with the clear button shown', (tester) async {
      await pumpField(tester, initialValue: 'morty');

      expect(fieldText(tester), 'morty');
      expect(find.byTooltip('Clear'), findsOneWidget);
      expect(changes, isEmpty);
    });

    testWidgets('tap clear → field emptied, empty query reported, button hidden', (tester) async {
      await pumpField(tester, initialValue: 'rick');

      await tester.tap(find.byTooltip('Clear'));
      await tester.pumpAndSettle();

      expect(fieldText(tester), isEmpty);
      expect(changes, ['']);
      expect(find.byTooltip('Clear'), findsNothing);
    });

    group('controller', () {
      late TextEditingController controller;

      setUp(() {
        controller = TextEditingController(text: 'rick');
      });

      tearDown(() {
        controller.dispose();
      });

      testWidgets('given → the field shows and edits its text', (tester) async {
        await pumpField(tester, controller: controller, initialValue: 'ignored');

        expect(fieldText(tester), 'rick');

        await tester.enterText(find.byType(TextField), 'morty');

        expect(controller.text, 'morty');
      });

      testWidgets('cleared from outside → clear button hidden', (tester) async {
        await pumpField(tester, controller: controller);
        expect(find.byTooltip('Clear'), findsOneWidget);

        controller.clear();
        await tester.pumpAndSettle();

        expect(find.byTooltip('Clear'), findsNothing);
      });

      testWidgets('tap clear → controller emptied and empty query reported', (tester) async {
        await pumpField(tester, controller: controller);

        await tester.tap(find.byTooltip('Clear'));
        await tester.pumpAndSettle();

        expect(controller.text, isEmpty);
        expect(changes, ['']);
      });

      testWidgets('field unmounted → controller still usable by its owner', (tester) async {
        await pumpField(tester, controller: controller);

        await tester.pumpWidget(const SizedBox());

        expect(tester.takeException(), isNull);
        expect(() => controller.addListener(() {}), returnsNormally);
        controller.text = 'morty';
        expect(controller.text, 'morty');
      });
    });
  });
}
