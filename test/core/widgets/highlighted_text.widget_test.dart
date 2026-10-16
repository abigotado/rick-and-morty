import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/core/widgets/highlighted_text.dart';

const _highlightColor = Color(0xFF97CE4C);

void main() {
  Future<Text> pumpText(WidgetTester tester, String text, String highlight) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HighlightedText(text, highlight: highlight, highlightColor: _highlightColor),
      ),
    );
    return tester.widget<Text>(find.byType(Text));
  }

  List<(String?, Color?)> spansOf(Text text) => [
    for (final span in (text.textSpan! as TextSpan).children!.cast<TextSpan>())
      (span.text, span.style?.color),
  ];

  group('HighlightedText', () {
    group('build', () {
      testWidgets('match in the middle → separate span in highlightColor', (tester) async {
        final text = await pumpText(tester, 'Rick Sanchez', 'sanch');

        expect(spansOf(text), [
          ('Rick ', null),
          ('Sanch', _highlightColor),
          ('ez', null),
        ]);
      });

      testWidgets('query in another case → original casing highlighted', (tester) async {
        final text = await pumpText(tester, 'Rick Sanchez', 'RICK');

        expect(spansOf(text), [
          ('', null),
          ('Rick', _highlightColor),
          (' Sanchez', null),
        ]);
      });

      testWidgets('several matches → only the first is highlighted', (tester) async {
        final text = await pumpText(tester, 'Rick and Rick', 'rick');

        expect(spansOf(text), [
          ('', null),
          ('Rick', _highlightColor),
          (' and Rick', null),
        ]);
      });

      testWidgets('query with regex characters → matched literally', (tester) async {
        final text = await pumpText(tester, 'Rick (C-137)', '(c-1');

        expect(spansOf(text), [
          ('Rick ', null),
          ('(C-1', _highlightColor),
          ('37)', null),
        ]);
      });

      testWidgets('no match → plain text', (tester) async {
        final text = await pumpText(tester, 'Rick Sanchez', 'morty');

        expect(text.data, 'Rick Sanchez');
        expect(text.textSpan, isNull);
      });

      testWidgets('empty highlight → plain text', (tester) async {
        final text = await pumpText(tester, 'Rick Sanchez', '');

        expect(text.data, 'Rick Sanchez');
        expect(text.textSpan, isNull);
      });
    });
  });
}
