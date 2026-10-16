import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/widgets/entrance.dart';
import 'package:rick_and_morty/features/characters/details/widgets/character_details_layout.dart';
import 'package:rick_and_morty/features/characters/details/widgets/character_info_tile.dart';
import 'package:rick_and_morty/features/characters/widgets/character_hero.dart';
import 'package:rick_and_morty/features/characters/widgets/character_status_chip.dart';

class CharacterDetailsContent extends StatelessWidget {
  const CharacterDetailsContent({required this.character, super.key});

  final CharacterEntity character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = [
      character.species,
      if (character.type.isNotEmpty) character.type,
      character.gender,
    ].join(' · ');
    return CharacterDetailsLayout(
      header: CharacterHero(
        characterId: character.id,
        url: character.imageUrl,
        previewExtent: CharacterHero.avatarExtent,
        semanticLabel: 'Portrait of ${character.name}',
      ),
      body: FadeIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Semantics(
              header: true,
              child: Text(character.name, style: theme.textTheme.headlineLarge),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CharacterStatusChip(status: character.status),
                Semantics(
                  label: switch (character.type) {
                    '' => null,
                    final type => 'Type: $type',
                  },
                  excludeSemantics: true,
                  child: Text(
                    summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _TraitTiles(species: character.species, gender: character.gender),
            ),
            CharacterInfoTile(label: 'Origin', value: character.origin, icon: Icons.public),
            CharacterInfoTile(
              label: 'Last known location',
              value: character.location,
              icon: Icons.place_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _TraitTiles extends StatelessWidget {
  const _TraitTiles({required this.species, required this.gender});

  final String species;
  final String gender;

  static const _stackedTextScale = 2.0;

  @override
  Widget build(BuildContext context) {
    final species = CharacterInfoTile(label: 'Species', value: this.species);
    final gender = CharacterInfoTile(label: 'Gender', value: this.gender);
    if (MediaQuery.textScalerOf(context).scale(1) >= _stackedTextScale) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [species, gender],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Expanded(child: species),
          Expanded(child: gender),
        ],
      ),
    );
  }
}
