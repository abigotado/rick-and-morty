import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CharacterImage extends StatelessWidget {
  const CharacterImage({
    required this.url,
    this.borderRadius = BorderRadius.zero,
    this.semanticLabel,
    this.decodeExtent,
    this.previewExtent,
    super.key,
  });

  final Uri? url;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  /// Logical size to decode the square avatar at; null keeps the source size.
  final double? decodeExtent;

  /// Decode extent of a smaller rendition, usually already in memory, shown while this one
  /// loads instead of the blank placeholder.
  final double? previewExtent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: semanticLabel != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: switch (url) {
          final url? => _CachedImage(
            url: url,
            decodeExtent: decodeExtent,
            placeholder: switch (previewExtent) {
              final extent? => _CachedImage(
                url: url,
                decodeExtent: extent,
                placeholder: const _ImagePlaceholder(),
              ),
              null => const _ImagePlaceholder(),
            },
          ),
          null => const _ImagePlaceholder(failed: true),
        },
      ),
    );
  }
}

class _CachedImage extends StatelessWidget {
  const _CachedImage({required this.url, required this.decodeExtent, required this.placeholder});

  final Uri url;
  final double? decodeExtent;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url.toString(),
      fit: BoxFit.cover,
      memCacheWidth: switch (decodeExtent) {
        final extent? => (extent * MediaQuery.devicePixelRatioOf(context)).ceil(),
        null => null,
      },
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => placeholder,
      errorWidget: (context, url, error) => const _ImagePlaceholder(failed: true),
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
