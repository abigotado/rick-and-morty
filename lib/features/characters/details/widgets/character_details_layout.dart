import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Scrollable details frame: a full-bleed [header] that fades into the ground, with [body]
/// overlapping its bottom edge. Capped at [maxContentWidth] and centered on wide screens.
class CharacterDetailsLayout extends StatelessWidget {
  const CharacterDetailsLayout({required this.header, required this.body, super.key});

  final Widget header;
  final Widget body;

  static const maxContentWidth = 640.0;
  static const maxHeaderHeight = 420.0;
  static const _minHeaderHeight = 280.0;
  static const _bodyOverlap = 80.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final frameMargin = math.max(0, (size.width - maxContentWidth) / 2);
    final headerHeight = (size.height * 0.55).clamp(
      _minHeaderHeight,
      maxHeaderHeight,
    );
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: headerHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [header, const _HeaderScrim()],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20 + math.max(0, padding.left - frameMargin),
                  headerHeight - _bodyOverlap,
                  20 + math.max(0, padding.right - frameMargin),
                  32 + padding.bottom,
                ),
                child: body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderScrim extends StatelessWidget {
  const _HeaderScrim();

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final clear = surface.withValues(alpha: 0);
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [surface.withValues(alpha: 0.45), clear, clear, surface],
            stops: const [0, 0.22, 0.55, 1],
          ),
        ),
      ),
    );
  }
}
