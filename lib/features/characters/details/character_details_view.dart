import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/features/characters/details/cubit/character_details_cubit.dart';
import 'package:rick_and_morty/features/characters/details/widgets/character_details_back_button.dart';
import 'package:rick_and_morty/features/characters/details/widgets/character_details_content.dart';
import 'package:rick_and_morty/features/characters/details/widgets/character_details_failure.dart';
import 'package:rick_and_morty/features/characters/details/widgets/character_details_layout.dart';
import 'package:rick_and_morty/features/characters/details/widgets/character_details_skeleton.dart';

class CharacterDetailsView extends StatelessWidget {
  const CharacterDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    const tapInset = (kMinInteractiveDimension - CharacterDetailsBackButton.size) / 2;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final frameLeft = math.max<double>(
            0,
            (constraints.maxWidth - CharacterDetailsLayout.maxContentWidth) / 2,
          );
          final frameInset = math.max<double>(0, padding.left - frameLeft);
          return Stack(
            children: [
              Positioned.fill(
                child: BlocBuilder<CharacterDetailsCubit, CharacterDetailsState>(
                  builder: (context, state) => switch (state) {
                    CharacterDetailsLoading() => const CharacterDetailsSkeleton(),
                    CharacterDetailsLoaded(:final character) => CharacterDetailsContent(
                      character: character,
                    ),
                    CharacterDetailsFailed(:final failure) => CharacterDetailsFailure(
                      failure: failure,
                      onRetry: () => unawaited(context.read<CharacterDetailsCubit>().load()),
                    ),
                  },
                ),
              ),
              Positioned(
                top: padding.top + 10 - tapInset,
                left: frameLeft + frameInset + 16 - tapInset,
                child: const CharacterDetailsBackButton(),
              ),
            ],
          );
        },
      ),
    );
  }
}
