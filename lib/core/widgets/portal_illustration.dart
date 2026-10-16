import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A portal-like emblem for empty and error states: dashed rings around [icon] that settle with a
/// short turn when they appear, or still, broken rings when [broken].
class PortalIllustration extends StatefulWidget {
  const PortalIllustration({
    required this.icon,
    required this.color,
    this.broken = false,
    super.key,
  });

  final IconData icon;
  final Color color;
  final bool broken;

  @override
  State<PortalIllustration> createState() => _PortalIllustrationState();
}

class _PortalIllustrationState extends State<PortalIllustration>
    with SingleTickerProviderStateMixin {
  static const _size = 120.0;

  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  late final Animation<double> _turns = Tween<double>(
    begin: -0.25,
    end: 0,
  ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_settle);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.broken || MediaQuery.disableAnimationsOf(context)) {
      _settle.value = 1;
    } else if (_settle.isDismissed) {
      unawaited(_settle.forward());
    }
  }

  @override
  void didUpdateWidget(PortalIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.broken) _settle.value = 1;
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: _size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.06),
              ),
              child: const SizedBox.square(dimension: 108),
            ),
            RotationTransition(
              turns: _turns,
              child: RepaintBoundary(
                child: CustomPaint(
                  size: const Size.square(_size),
                  painter: _RingsPainter(color: widget.color, broken: widget.broken),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainer,
                border: Border.all(color: widget.color, width: 2),
              ),
              child: SizedBox.square(
                dimension: 40,
                child: Icon(widget.icon, size: 20, color: widget.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  const _RingsPainter({required this.color, required this.broken});

  final Color color;
  final bool broken;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    if (broken) {
      paint.color = color.withValues(alpha: 0.45);
      final rect = Rect.fromCircle(center: center, radius: 46);
      for (final (start, sweep) in [(-1.6, 1.1), (0.25, 1.75), (2.75, 1.25)]) {
        canvas.drawArc(rect, start, sweep, false, paint);
      }
      return;
    }
    _dashedCircle(canvas, center, 46, 6, 10, paint..color = color.withValues(alpha: 0.35));
    _dashedCircle(canvas, center, 34, 20, 8, paint..color = color.withValues(alpha: 0.6));
  }

  void _dashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    double dash,
    double gap,
    Paint paint,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final circumference = 2 * math.pi * radius;
    final count = (circumference / (dash + gap)).floor();
    final step = 2 * math.pi / count;
    final sweep = step * dash / (dash + gap);
    for (var i = 0; i < count; i++) {
      canvas.drawArc(rect, i * step, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter oldDelegate) =>
      color != oldDelegate.color || broken != oldDelegate.broken;
}
