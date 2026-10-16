import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/widgets/skeleton.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_sliver_items.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_tile.dart';

class CharacterListSkeleton extends StatelessWidget {
  const CharacterListSkeleton({super.key});

  static const _nameWidths = [0.62, 0.48, 0.7, 0.54, 0.66, 0.44, 0.58, 0.5];

  @override
  Widget build(BuildContext context) {
    final grid = MediaQuery.sizeOf(context).width >= CharacterSliverItems.gridBreakpoint;
    return SliverSemantics(
      label: 'Loading characters',
      sliver: SliverSafeArea(
        top: false,
        sliver: Shimmer(
          child: grid
              ? SliverPadding(
                  padding: CharacterSliverItems.gridPadding,
                  sliver: SliverGrid.builder(
                    gridDelegate: CharacterSliverItems.gridDelegate,
                    itemCount: 10,
                    itemBuilder: (context, index) =>
                        _CardSkeleton(nameWidth: _nameWidths[index % _nameWidths.length]),
                  ),
                )
              : SliverPadding(
                  padding: CharacterSliverItems.listPadding,
                  sliver: SliverList.separated(
                    itemCount: _nameWidths.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: CharacterSliverItems.itemSpacing),
                    itemBuilder: (context, index) => _TileSkeleton(nameWidth: _nameWidths[index]),
                  ),
                ),
        ),
      ),
    );
  }
}

class _SkeletonSurface extends StatelessWidget {
  const _SkeletonSurface({required this.borderRadius, required this.child});

  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        child: ClipRRect(borderRadius: borderRadius, child: child),
      ),
    );
  }
}

class _TileSkeleton extends StatelessWidget {
  const _TileSkeleton({required this.nameWidth});

  final double nameWidth;

  @override
  Widget build(BuildContext context) {
    return _SkeletonSurface(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          spacing: 14,
          children: [
            const SkeletonBox(
              width: CharacterTile.imageSize,
              height: CharacterTile.imageSize,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  FractionallySizedBox(
                    widthFactor: nameWidth,
                    child: const SkeletonBox(height: 16),
                  ),
                  const _PillSkeleton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({required this.nameWidth});

  final double nameWidth;

  @override
  Widget build(BuildContext context) {
    return _SkeletonSurface(
      borderRadius: const BorderRadius.all(Radius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: SkeletonBox(height: double.infinity, borderRadius: BorderRadius.zero),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                FractionallySizedBox(
                  widthFactor: nameWidth + 0.2,
                  child: const SkeletonBox(height: 16),
                ),
                const _PillSkeleton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillSkeleton extends StatelessWidget {
  const _PillSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonBox(
      width: 92,
      height: 20,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );
  }
}
