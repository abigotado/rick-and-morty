import 'package:flutter/widgets.dart';

/// Requests the next page when the scroll view gets close to its end.
///
/// Attach [scrollController] to the scroll view and route its metrics through
/// [onScrollMetricsChanged]. Call [scheduleLoadMoreCheck] when new items arrive: a page that does
/// not fill the viewport never produces a scroll event.
mixin InfiniteScrollMixin<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();

  double get loadMoreThreshold => 300;

  bool get canLoadMore;

  void onLoadMore();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_loadMoreIfNearEnd);
    scheduleLoadMoreCheck();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scheduleLoadMoreCheck() {
    WidgetsBinding.instance
      ..addPostFrameCallback((_) => _loadMoreIfNearEnd())
      ..ensureVisualUpdate();
  }

  bool onScrollMetricsChanged(ScrollMetricsNotification notification) {
    _loadMoreIfNearEnd();
    return false;
  }

  void _loadMoreIfNearEnd() {
    if (!mounted || !scrollController.hasClients || !canLoadMore) return;
    if (scrollController.position.extentAfter < loadMoreThreshold) onLoadMore();
  }
}
