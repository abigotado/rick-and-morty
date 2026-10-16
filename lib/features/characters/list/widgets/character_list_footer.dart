import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/features/characters/list/bloc/characters_bloc.dart';

class CharacterListFooter extends StatelessWidget {
  const CharacterListFooter({required this.status, super.key});

  final NextPageStatus status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: switch (status) {
        NextPageStatus.failure => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            const Flexible(child: Text("Couldn't load more characters")),
            TextButton(
              onPressed: () => context.read<CharactersBloc>().add(const CharactersRetried()),
              child: const Text('Retry'),
            ),
          ],
        ),
        NextPageStatus.idle || NextPageStatus.loading => const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading more'),
        ),
      },
    );
  }
}
