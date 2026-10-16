import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/widgets/character_image.dart';

/// A [CharacterImage] that flies between the list and the details screen.
///
/// The flight morphs the corners between both ends and shows the sharpest rendition of the
/// image, falling back to the smaller one already in memory while the larger one loads.
class CharacterHero extends StatelessWidget {
  const CharacterHero({
    required this.characterId,
    required this.url,
    this.borderRadius = BorderRadius.zero,
    this.decodeExtent,
    this.previewExtent,
    this.semanticLabel,
    super.key,
  });

  /// Shared by the list avatar and the details header so the image flies between them.
  static Object heroTag(int characterId) => 'character-image-$characterId';

  /// Decode size of the list avatar, which the details header shows while its image loads.
  static const avatarExtent = 68.0;

  final int characterId;
  final Uri? url;
  final BorderRadius borderRadius;
  final double? decodeExtent;
  final double? previewExtent;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag(characterId),
      transitionOnUserGestures: true,
      flightShuttleBuilder: (flightContext, animation, direction, fromHeroContext, toHeroContext) =>
          _CharacterHeroShuttle(
            animation: animation,
            direction: direction,
            from: fromHeroContext.findAncestorWidgetOfExactType<CharacterHero>() ?? this,
            to: toHeroContext.findAncestorWidgetOfExactType<CharacterHero>() ?? this,
          ),
      child: CharacterImage(
        url: url,
        borderRadius: borderRadius,
        decodeExtent: decodeExtent,
        previewExtent: previewExtent,
        semanticLabel: semanticLabel,
      ),
    );
  }
}

class _CharacterHeroShuttle extends AnimatedWidget {
  const _CharacterHeroShuttle({
    required Animation<double> animation,
    required this.direction,
    required this.from,
    required this.to,
  }) : super(listenable: animation);

  final HeroFlightDirection direction;
  final CharacterHero from;
  final CharacterHero to;

  @override
  Widget build(BuildContext context) {
    final (lower, upper) = switch (direction) {
      HeroFlightDirection.push => (from, to),
      HeroFlightDirection.pop => (to, from),
    };
    final (decodeExtent, previewExtent) = switch ((from.decodeExtent, to.decodeExtent)) {
      (final a?, final b?) => (math.max(a, b), math.min(a, b)),
      (final extent?, null) || (null, final extent?) => (null, extent),
      (null, null) => (null, null),
    };
    return CharacterImage(
      url: upper.url,
      borderRadius: BorderRadius.lerp(
        lower.borderRadius,
        upper.borderRadius,
        (listenable as Animation<double>).value,
      )!,
      decodeExtent: decodeExtent,
      previewExtent: previewExtent,
    );
  }
}
