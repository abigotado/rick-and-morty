import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';

class CharacterStatusChip extends StatelessWidget {
  const CharacterStatusChip({required this.status, super.key});

  final CharacterStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (label, color) = switch (status) {
      CharacterStatus.alive => ('Alive', colorScheme.primary),
      CharacterStatus.dead => ('Dead', colorScheme.error),
      CharacterStatus.unknown => ('Unknown', colorScheme.outline),
    };
    return Semantics(
      label: 'Status: $label',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: color.withValues(alpha: 0.14),
          shape: const StadiumBorder(),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(7, 3, 9, 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const SizedBox.square(dimension: 7),
              ),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Color.lerp(color, colorScheme.onSurface, 0.35),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
