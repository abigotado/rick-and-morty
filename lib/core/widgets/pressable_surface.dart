import 'package:flutter/material.dart';

/// A card surface that shrinks slightly while pressed and lifts on hover, with an ink ripple
/// clipped to its shape.
///
/// The ink layer sits above [child] so the ripple stays visible over opaque content such as a
/// full-bleed image; the surface reads as a single button labelled by [child].
class PressableSurface extends StatefulWidget {
  const PressableSurface({
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.clipBehavior = Clip.none,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final Clip clipBehavior;

  @override
  State<PressableSurface> createState() => _PressableSurfaceState();
}

class _PressableSurfaceState extends State<PressableSurface> {
  static const _pressDuration = Duration(milliseconds: 120);
  static const _hoverDuration = Duration(milliseconds: 160);

  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final interactive = widget.onTap != null;
    final lifted = interactive && _hovered;
    final animate = !MediaQuery.disableAnimationsOf(context);
    return MergeSemantics(
      child: Semantics(
        button: interactive,
        child: MouseRegion(
          onEnter: interactive ? (_) => setState(() => _hovered = true) : null,
          onExit: interactive ? (_) => setState(() => _hovered = false) : null,
          child: AnimatedScale(
            scale: interactive && _pressed ? 0.98 : 1,
            duration: animate ? _pressDuration : Duration.zero,
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: animate ? _hoverDuration : Duration.zero,
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, lifted ? -3 : 0, 0),
              clipBehavior: widget.clipBehavior,
              decoration: ShapeDecoration(
                color: colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: widget.borderRadius,
                  side: BorderSide(
                    color: lifted
                        ? Color.lerp(colorScheme.outlineVariant, colorScheme.outline, 0.3)!
                        : colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  widget.child,
                  Positioned.fill(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: widget.onTap,
                        onHighlightChanged: (pressed) => setState(() => _pressed = pressed),
                        borderRadius: widget.borderRadius,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
