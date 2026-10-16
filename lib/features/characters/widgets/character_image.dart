import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CharacterImage extends StatelessWidget {
  const CharacterImage({
    required this.url,
    this.borderRadius = BorderRadius.zero,
    this.semanticLabel,
    this.decodeExtent,
    super.key,
  });

  final Uri? url;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  /// Logical size to decode the square avatar at; null keeps the source size.
  final double? decodeExtent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: semanticLabel != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: switch (url) {
          final url? => CachedNetworkImage(
            imageUrl: url.toString(),
            fit: BoxFit.cover,
            memCacheWidth: switch (decodeExtent) {
              final extent? => (extent * MediaQuery.devicePixelRatioOf(context)).ceil(),
              null => null,
            },
            fadeInDuration: const Duration(milliseconds: 200),
            placeholder: (context, url) => const _ImagePlaceholder(),
            errorWidget: (context, url, error) => const _ImagePlaceholder(failed: true),
          ),
          null => const _ImagePlaceholder(failed: true),
        },
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.failed = false});

  final bool failed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: failed
          ? Center(child: Icon(Icons.broken_image_outlined, color: colorScheme.outline))
          : null,
    );
  }
}
