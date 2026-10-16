import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/domain/character.dart';

class CharacterImage extends StatelessWidget {
  const CharacterImage({
    required this.character,
    this.borderRadius = BorderRadius.zero,
    this.semanticLabel,
    super.key,
  });

  final Character character;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      image: semanticLabel != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: character.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => ColoredBox(color: colorScheme.surfaceContainerHighest),
          errorWidget: (context, url, error) => ColoredBox(
            color: colorScheme.surfaceContainerHighest,
            child: Icon(Icons.broken_image_outlined, color: colorScheme.outline),
          ),
        ),
      ),
    );
  }
}
