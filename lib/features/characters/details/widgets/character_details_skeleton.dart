import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/widgets/skeleton.dart';
import 'package:rick_and_morty/features/characters/details/widgets/character_details_layout.dart';

class CharacterDetailsSkeleton extends StatelessWidget {
  const CharacterDetailsSkeleton({super.key});

  static const _tileRadius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading character',
      container: true,
      child: const Shimmer(
        child: CharacterDetailsLayout(
          header: SkeletonBox(height: double.infinity, borderRadius: BorderRadius.zero),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              SkeletonBox(width: 220, height: 40, borderRadius: _tileRadius),
              SkeletonBox(
                width: 170,
                height: 26,
                borderRadius: BorderRadius.all(Radius.circular(13)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  spacing: 10,
                  children: [
                    Expanded(child: SkeletonBox(height: 72, borderRadius: _tileRadius)),
                    Expanded(child: SkeletonBox(height: 72, borderRadius: _tileRadius)),
                  ],
                ),
              ),
              SkeletonBox(width: double.infinity, height: 72, borderRadius: _tileRadius),
              SkeletonBox(width: double.infinity, height: 72, borderRadius: _tileRadius),
            ],
          ),
        ),
      ),
    );
  }
}
