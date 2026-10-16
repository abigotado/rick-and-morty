import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// A pinned header whose large title shrinks into the toolbar as the content scrolls, with
/// [bottom] (e.g. a search field) pinned underneath. The collapse follows the scroll offset, so it
/// never jumps or plays on a timer.
class CollapsingHeader extends StatelessWidget {
  const CollapsingHeader({
    required this.title,
    required this.bottom,
    required this.bottomHeight,
    this.subtitle,
    super.key,
  });

  final String title;
  final Widget? subtitle;
  final Widget bottom;
  final double bottomHeight;

  static const _maxTextScale = 1.3;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: _maxTextScale);
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: _maxTextScale,
      child: SliverPersistentHeader(
        pinned: true,
        delegate: _CollapsingHeaderDelegate(
          title: title,
          subtitle: subtitle,
          bottom: bottom,
          bottomHeight: bottomHeight,
          topPadding: MediaQuery.paddingOf(context).top,
          titleHeight: textScaler.scale(40),
          subtitleHeight: textScaler.scale(24),
        ),
      ),
    );
  }
}

class _CollapsingHeaderDelegate extends SliverPersistentHeaderDelegate {
  _CollapsingHeaderDelegate({
    required this.title,
    required this.subtitle,
    required this.bottom,
    required this.bottomHeight,
    required this.topPadding,
    required this.titleHeight,
    required this.subtitleHeight,
  });

  final String title;
  final Widget? subtitle;
  final Widget bottom;
  final double bottomHeight;
  final double topPadding;
  final double titleHeight;
  final double subtitleHeight;

  static const _toolbarHeight = 56.0;
  static const _expandedTop = 24.0;
  static const _collapsedTitleSize = 20.0;

  double get _expandedHeight => _expandedTop + titleHeight + subtitleHeight + 4;

  @override
  double get minExtent => topPadding + _toolbarHeight + bottomHeight;

  @override
  double get maxExtent => topPadding + _expandedHeight + bottomHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleStyle = theme.textTheme.headlineLarge!;
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final scale = lerpDouble(1, _collapsedTitleSize / titleStyle.fontSize!, t)!;
    final collapsedTitleTop = (_toolbarHeight - titleHeight * scale) / 2;
    final titleTop = topPadding + lerpDouble(_expandedTop, collapsedTitleTop, t)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.lerp(colorScheme.surface, colorScheme.surfaceContainerLow, t),
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: t)),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (subtitle case final subtitle?)
              PositionedDirectional(
                start: 16,
                end: 16,
                top: topPadding + _expandedTop + titleHeight + 4,
                child: Opacity(
                  opacity: (1 - t * 2).clamp(0.0, 1.0),
                  child: DefaultTextStyle(
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: subtitle,
                  ),
                ),
              ),
            PositionedDirectional(
              start: 16,
              end: 16,
              top: titleTop,
              child: Transform.scale(
                scale: scale,
                alignment: AlignmentDirectional.topStart,
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 0,
              height: bottomHeight,
              child: bottom,
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_CollapsingHeaderDelegate oldDelegate) =>
      title != oldDelegate.title ||
      subtitle != oldDelegate.subtitle ||
      bottom != oldDelegate.bottom ||
      bottomHeight != oldDelegate.bottomHeight ||
      topPadding != oldDelegate.topPadding ||
      titleHeight != oldDelegate.titleHeight ||
      subtitleHeight != oldDelegate.subtitleHeight;
}
