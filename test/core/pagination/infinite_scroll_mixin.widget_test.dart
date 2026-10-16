import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/core/pagination/infinite_scroll_mixin.dart';

const _itemExtent = 100.0;

class _Feed extends StatefulWidget {
  const _Feed({
    required this.itemCount,
    required this.onLoadMore,
    this.canLoadMore = true,
    this.listensToMetrics = false,
  });

  final int itemCount;
  final VoidCallback onLoadMore;
  final bool canLoadMore;
  final bool listensToMetrics;

  @override
  State<_Feed> createState() => _FeedState();
}

class _FeedState extends State<_Feed> with InfiniteScrollMixin<_Feed> {
  @override
  bool get canLoadMore => widget.canLoadMore;

  @override
  void onLoadMore() => widget.onLoadMore();

  @override
  void didUpdateWidget(_Feed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) scheduleLoadMoreCheck();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: widget.listensToMetrics ? onScrollMetricsChanged : null,
      child: ListView.builder(
        controller: scrollController,
        itemExtent: _itemExtent,
        itemCount: widget.itemCount,
        itemBuilder: (context, index) => Text('Item $index'),
      ),
    );
  }
}

void main() {
  group('InfiniteScrollMixin', () {
    late int loadMoreCalls;

    setUp(() {
      loadMoreCalls = 0;
    });

    void countLoadMore() => loadMoreCalls++;

    Future<void> pumpFeed(
      WidgetTester tester, {
      required int itemCount,
      bool canLoadMore = true,
      bool listensToMetrics = false,
    }) {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(400, 600);
      addTearDown(tester.view.reset);
      return tester.pumpWidget(
        MaterialApp(
          home: _Feed(
            itemCount: itemCount,
            onLoadMore: countLoadMore,
            canLoadMore: canLoadMore,
            listensToMetrics: listensToMetrics,
          ),
        ),
      );
    }

    ScrollController controllerOf(WidgetTester tester) =>
        tester.state<_FeedState>(find.byType(_Feed)).scrollController;

    group('scrolling', () {
      testWidgets('within the threshold of the end → onLoadMore', (tester) async {
        await pumpFeed(tester, itemCount: 30);
        expect(loadMoreCalls, 0);

        await tester.drag(find.byType(ListView), const Offset(0, -2200));
        await tester.pump();

        expect(controllerOf(tester).position.extentAfter, lessThan(300));
        expect(loadMoreCalls, greaterThan(0));
      });

      testWidgets('a little, far from the end → no onLoadMore', (tester) async {
        await pumpFeed(tester, itemCount: 30);

        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pump();

        expect(controllerOf(tester).position.extentAfter, greaterThan(300));
        expect(loadMoreCalls, 0);
      });

      testWidgets('to the very end with canLoadMore false → no onLoadMore', (tester) async {
        await pumpFeed(tester, itemCount: 30, canLoadMore: false);

        controllerOf(tester).jumpTo(controllerOf(tester).position.maxScrollExtent);
        await tester.pump();

        expect(loadMoreCalls, 0);
      });
    });

    group('first frame', () {
      testWidgets('content shorter than the viewport → onLoadMore once', (tester) async {
        await pumpFeed(tester, itemCount: 3);

        expect(loadMoreCalls, 1);
      });

      testWidgets('content shorter than the viewport with canLoadMore false → no onLoadMore', (
        tester,
      ) async {
        await pumpFeed(tester, itemCount: 3, canLoadMore: false);

        expect(loadMoreCalls, 0);
      });

      testWidgets('content filling the viewport → no onLoadMore', (tester) async {
        await pumpFeed(tester, itemCount: 30);

        expect(loadMoreCalls, 0);
      });
    });

    group('scheduleLoadMoreCheck', () {
      testWidgets('content grows but still short of the viewport → onLoadMore again', (
        tester,
      ) async {
        await pumpFeed(tester, itemCount: 3);
        expect(loadMoreCalls, 1);

        await pumpFeed(tester, itemCount: 5);

        expect(loadMoreCalls, 2);
      });

      testWidgets('content grows past the threshold → checked after layout, no onLoadMore', (
        tester,
      ) async {
        await pumpFeed(tester, itemCount: 3);
        expect(loadMoreCalls, 1);

        await pumpFeed(tester, itemCount: 30);

        expect(loadMoreCalls, 1);
      });

      testWidgets('content shrinks within the threshold without scrolling → onLoadMore', (
        tester,
      ) async {
        await pumpFeed(tester, itemCount: 30);
        expect(loadMoreCalls, 0);

        await pumpFeed(tester, itemCount: 8);

        expect(loadMoreCalls, 1);
      });
    });

    group('onScrollMetricsChanged', () {
      testWidgets('viewport grows within the threshold of the end → onLoadMore', (
        tester,
      ) async {
        await pumpFeed(tester, itemCount: 10, listensToMetrics: true);
        expect(loadMoreCalls, 0);

        tester.view.physicalSize = const Size(400, 800);
        await tester.pump();
        await tester.pump();

        expect(loadMoreCalls, 1);
      });
    });

    group('under an opaque route', () {
      Future<void> pumpBehindRoute(
        WidgetTester tester, {
        required int itemCount,
        bool covered = true,
      }) {
        tester.view
          ..devicePixelRatio = 1
          ..physicalSize = const Size(400, 600);
        addTearDown(tester.view.reset);
        return tester.pumpWidget(
          MaterialApp(
            home: Navigator(
              pages: [
                MaterialPage<void>(
                  key: const ValueKey('feed'),
                  child: _Feed(
                    itemCount: itemCount,
                    onLoadMore: countLoadMore,
                    listensToMetrics: true,
                  ),
                ),
                if (covered)
                  const MaterialPage<void>(
                    key: ValueKey('top'),
                    child: Scaffold(body: Text('Top')),
                  ),
              ],
              onDidRemovePage: (page) {},
            ),
          ),
        );
      }

      testWidgets('never laid out, items arrive → no throw and no onLoadMore', (tester) async {
        await pumpBehindRoute(tester, itemCount: 3);
        await tester.pump();

        await pumpBehindRoute(tester, itemCount: 5);
        await tester.pump();

        expect(tester.takeException(), isNull);
        final feed = tester.state<_FeedState>(find.byType(_Feed, skipOffstage: false));
        expect(feed.scrollController.position.hasContentDimensions, isFalse);
        expect(loadMoreCalls, 0);
      });

      testWidgets('route above removed, short content laid out → onLoadMore', (tester) async {
        await pumpBehindRoute(tester, itemCount: 3);
        await pumpBehindRoute(tester, itemCount: 5);
        await tester.pump();
        expect(loadMoreCalls, 0);

        await pumpBehindRoute(tester, itemCount: 5, covered: false);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(loadMoreCalls, greaterThan(0));
      });
    });

    group('dispose', () {
      testWidgets('state unmounted → scrollController disposed', (tester) async {
        await pumpFeed(tester, itemCount: 30);
        final controller = controllerOf(tester);

        await tester.pumpWidget(const SizedBox());

        expect(tester.takeException(), isNull);
        expect(() => controller.addListener(() {}), throwsFlutterError);
      });
    });
  });
}
