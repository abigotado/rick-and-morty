import 'dart:async';

import 'package:flutter/material.dart';

/// Drives one shared shimmer for every [SkeletonBox] below it.
class Shimmer extends StatefulWidget {
  const Shimmer({required this.child, super.key});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ShimmerScope(animation: _controller, child: widget.child);
  }
}

class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({required this.animation, required super.child});

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_ShimmerScope oldWidget) => animation != oldWidget.animation;
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    required this.height,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    super.key,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = Color.lerp(colorScheme.surfaceContainer, colorScheme.surfaceContainerHigh, 0.5)!;
    final highlight = Color.alphaBlend(colorScheme.onSurface.withValues(alpha: 0.06), base);
    final animation =
        context.dependOnInheritedWidgetOfExactType<_ShimmerScope>()?.animation ??
        const AlwaysStoppedAnimation(0);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SkeletonPainter(
          animation: animation,
          base: base,
          highlight: highlight,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

/// Sweeps a fixed-width highlight a fixed distance per cycle, so boxes of any width shimmer at
/// the same speed, and repaints without rebuilding.
class _SkeletonPainter extends CustomPainter {
  _SkeletonPainter({
    required this.animation,
    required this.base,
    required this.highlight,
    required this.borderRadius,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color base;
  final Color highlight;
  final BorderRadius borderRadius;

  static const _band = 160.0;
  static const _travel = 800.0;

  @override
  void paint(Canvas canvas, Size size) {
    final left = animation.value * _travel - _band;
    final shader = LinearGradient(
      colors: [base, highlight, base],
    ).createShader(Rect.fromLTWH(left, 0, _band, size.height));
    canvas.drawRRect(borderRadius.toRRect(Offset.zero & size), Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_SkeletonPainter oldDelegate) =>
      animation != oldDelegate.animation ||
      base != oldDelegate.base ||
      highlight != oldDelegate.highlight ||
      borderRadius != oldDelegate.borderRadius;
}
