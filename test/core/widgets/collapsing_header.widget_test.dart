import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/app/theme.dart';
import 'package:rick_and_morty/core/widgets/collapsing_header.dart';

const _bottomKey = Key('bottom');
const _bottomHeight = 60.0;
const _toolbarHeight = 56.0;

void main() {
  group('CollapsingHeader', () {
    late ScrollController controller;

    setUp(() {
      controller = ScrollController();
    });

    tearDown(() {
      controller.dispose();
    });

    Future<void> pumpHeader(WidgetTester tester) {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: CustomScrollView(
              controller: controller,
              slivers: [
                const CollapsingHeader(
                  title: 'Characters',
                  subtitle: Text('826 across the multiverse'),
                  bottomHeight: _bottomHeight,
                  bottom: SizedBox(key: _bottomKey, height: _bottomHeight),
                ),
                SliverList.builder(
                  itemCount: 50,
                  itemBuilder: (context, index) => SizedBox(height: 80, child: Text('Item $index')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final title = find.text('Characters');

    double subtitleOpacity(WidgetTester tester) => tester
        .widget<Opacity>(
          find.ancestor(of: find.text('826 across the multiverse'), matching: find.byType(Opacity)),
        )
        .opacity;

    double titleScale(WidgetTester tester) =>
        tester.getRect(title).height / tester.getSize(title).height;

    group('build', () {
      testWidgets('not scrolled → title at full size and subtitle visible', (tester) async {
        await pumpHeader(tester);

        expect(tester.widget<Text>(title).style?.fontSize, 34);
        expect(titleScale(tester), 1);
        expect(subtitleOpacity(tester), 1);
        expect(tester.getRect(find.byKey(_bottomKey)).top, greaterThan(_toolbarHeight));
      });

      testWidgets(
        'scrolled past the collapse range → toolbar title, subtitle hidden, bottom pinned',
        (
          tester,
        ) async {
          await pumpHeader(tester);

          controller.jumpTo(1000);
          await tester.pump();

          expect(titleScale(tester), moreOrLessEquals(20 / 34));
          expect(subtitleOpacity(tester), 0);
          expect(tester.getRect(title).bottom, lessThanOrEqualTo(_toolbarHeight));
          expect(
            tester.getRect(find.byKey(_bottomKey)),
            const Rect.fromLTWH(0, _toolbarHeight, 400, _bottomHeight),
          );
        },
      );

      testWidgets('half collapsed → title between the two sizes, subtitle already faded', (
        tester,
      ) async {
        await pumpHeader(tester);
        final expandedBottomTop = tester.getRect(find.byKey(_bottomKey)).top;

        controller.jumpTo((expandedBottomTop - _toolbarHeight) / 2);
        await tester.pump();

        expect(titleScale(tester), allOf(lessThan(1), greaterThan(20 / 34)));
        expect(subtitleOpacity(tester), 0);
      });

      testWidgets('large text → subtitle stays above the bottom and nothing overflows', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = 3;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await pumpHeader(tester);

        expect(tester.takeException(), isNull);
        expect(
          tester.getRect(find.text('826 across the multiverse')).bottom,
          lessThanOrEqualTo(tester.getRect(find.byKey(_bottomKey)).top),
        );
        expect(
          tester.getRect(title).bottom,
          lessThanOrEqualTo(tester.getRect(find.text('826 across the multiverse')).top),
        );
      });
    });
  });
}
