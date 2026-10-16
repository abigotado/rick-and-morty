import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fades its child in once, when it is first built.
class FadeIn extends StatelessWidget {
  const FadeIn({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }
}

/// Fades and lifts an item into place, staggered by its [index], while [animation] runs from 0
/// to 1 over [totalDuration]. Items past the cap share the last slot.
class StaggeredEntrance extends StatelessWidget {
  const StaggeredEntrance({
    required this.animation,
    required this.index,
    required this.child,
    super.key,
  });

  final Animation<double> animation;
  final int index;
  final Widget child;

  static const _itemDuration = Duration(milliseconds: 280);
  static const _stagger = Duration(milliseconds: 40);
  static const _maxStaggered = 8;
  static const _rise = 12.0;

  static Duration get totalDuration => _itemDuration + _stagger * (_maxStaggered - 1);

  @override
  Widget build(BuildContext context) {
    final total = totalDuration.inMilliseconds;
    final begin = math.min(index, _maxStaggered - 1) * _stagger.inMilliseconds / total;
    final interval = Interval(
      begin,
      begin + _itemDuration.inMilliseconds / total,
      curve: Curves.easeOutCubic,
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = interval.transform(animation.value);
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, _rise * (1 - value)), child: child),
        );
      },
      child: child,
    );
  }
}
