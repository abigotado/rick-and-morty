import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Puts a decoded image into the memory cache under the key [CachedNetworkImage] uses for
/// [url] decoded at [cacheWidth] physical pixels (null: source size), as if it had loaded.
Future<ui.Image> seedCachedImage(WidgetTester tester, Uri url, {int? cacheWidth}) async {
  final image = (await tester.runAsync(() => createTestImage(width: 4, height: 4)))!;
  final provider = ResizeImage.resizeIfNeeded(
    cacheWidth,
    null,
    CachedNetworkImageProvider(url.toString()),
  );
  final key = await provider.obtainKey(ImageConfiguration.empty);
  imageCache
    ..evict(key)
    ..putIfAbsent(
      key,
      () => OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image: image))),
    );
  addTearDown(() {
    imageCache
      ..clear()
      ..clearLiveImages();
  });
  return image;
}
