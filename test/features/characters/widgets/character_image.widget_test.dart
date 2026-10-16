import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/features/characters/widgets/character_image.dart';

void main() {
  group('CharacterImage', () {
    final avatarUrl = Uri.parse('https://rickandmortyapi.com/api/character/avatar/1.jpeg');

    Future<void> pumpImage(
      WidgetTester tester, {
      required Uri? url,
      Size size = const Size(72, 72),
      double devicePixelRatio = 3,
      String? semanticLabel,
      double? decodeExtent,
    }) {
      tester.view.devicePixelRatio = devicePixelRatio;
      addTearDown(tester.view.resetDevicePixelRatio);
      return tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox.fromSize(
              size: size,
              child: CharacterImage(
                url: url,
                semanticLabel: semanticLabel,
                decodeExtent: decodeExtent,
              ),
            ),
          ),
        ),
      );
    }

    CachedNetworkImage networkImage(WidgetTester tester) =>
        tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));

    group('build', () {
      testWidgets('url null → broken image icon and no network image', (tester) async {
        await pumpImage(tester, url: null);

        expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
        expect(find.byType(CachedNetworkImage), findsNothing);
      });

      testWidgets('url set → network image for that url', (tester) async {
        await pumpImage(tester, url: avatarUrl);

        expect(networkImage(tester).imageUrl, avatarUrl.toString());
        expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
      });

      testWidgets('decodeExtent 72 at dpr 3 → memCacheWidth 216', (tester) async {
        await pumpImage(tester, url: avatarUrl, decodeExtent: 72);

        expect(networkImage(tester).memCacheWidth, 216);
      });

      testWidgets('decodeExtent 71.4 at dpr 3 → rounds up to 215', (tester) async {
        await pumpImage(tester, url: avatarUrl, decodeExtent: 71.4);

        expect(networkImage(tester).memCacheWidth, 215);
      });

      testWidgets('no decodeExtent → decoded at source size', (tester) async {
        await pumpImage(tester, url: avatarUrl, size: const Size(200, 260));

        expect(networkImage(tester).memCacheWidth, isNull);
      });

      testWidgets('parent resized → same image cache key', (tester) async {
        await pumpImage(tester, url: avatarUrl, decodeExtent: 72);
        final before = networkImage(tester).memCacheWidth;

        await pumpImage(tester, url: avatarUrl, decodeExtent: 72, size: const Size(73, 73));

        expect(networkImage(tester).memCacheWidth, before);
      });

      testWidgets('semanticLabel set → labelled image semantics', (tester) async {
        await pumpImage(tester, url: avatarUrl, semanticLabel: 'Rick Sanchez');

        expect(
          tester.getSemantics(find.byType(CharacterImage)),
          isSemantics(label: 'Rick Sanchez', isImage: true),
        );
      });

      testWidgets('semanticLabel null → no image semantics', (tester) async {
        await pumpImage(tester, url: avatarUrl);

        expect(
          tester.getSemantics(find.byType(CharacterImage)),
          isNot(isSemantics(isImage: true)),
        );
      });
    });
  });
}
