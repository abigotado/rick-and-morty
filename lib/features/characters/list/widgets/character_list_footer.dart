import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/features/characters/list/bloc/characters_bloc.dart';

class CharacterListFooter extends StatelessWidget {
  const CharacterListFooter({required this.status, super.key});

  final NextPageStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: switch (status) {
        NextPageStatus.failure => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Flexible(
              child: Text(
                "Couldn't load more characters",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.read<CharactersBloc>().add(const CharactersRetried()),
              child: const Text('Retry'),
            ),
          ],
        ),
        NextPageStatus.idle || NextPageStatus.loading => const Center(
          child: SizedBox.square(
            dimension: 28,
            child: CircularProgressIndicator(strokeWidth: 3, semanticsLabel: 'Loading more'),
          ),
        ),
      },
    );
  }
}
