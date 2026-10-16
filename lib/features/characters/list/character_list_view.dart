import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/core/pagination/infinite_scroll_mixin.dart';
import 'package:rick_and_morty/core/widgets/entrance.dart';
import 'package:rick_and_morty/features/characters/list/bloc/characters_bloc.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_list_content.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_list_header.dart';

class CharacterListView extends StatefulWidget {
  const CharacterListView({super.key});

  @override
  State<CharacterListView> createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView>
    with InfiniteScrollMixin, SingleTickerProviderStateMixin {
  late final TextEditingController _searchController = TextEditingController(
    text: context.read<CharactersBloc>().state.query,
  );
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: StaggeredEntrance.totalDuration,
    value: 1,
  );

  @override
  bool get canLoadMore => context.read<CharactersBloc>().state.canLoadMore;

  @override
  void onLoadMore() => context.read<CharactersBloc>().add(const CharactersNextPageRequested());

  @override
  void dispose() {
    _searchController.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<CharactersBloc>().add(const CharactersQueryChanged(''));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CharactersBloc, CharactersState>(
          listenWhen: (previous, current) =>
              current.canLoadMore &&
              (previous.status != current.status || previous.characters != current.characters),
          listener: (context, state) => scheduleLoadMoreCheck(),
        ),
        BlocListener<CharactersBloc, CharactersState>(
          listenWhen: (previous, current) => previous.query != current.query,
          listener: (context, state) {
            if (scrollController.hasClients) scrollController.jumpTo(0);
          },
        ),
        BlocListener<CharactersBloc, CharactersState>(
          listenWhen: (previous, current) =>
              previous.status != CharactersStatus.success &&
              current.status == CharactersStatus.success &&
              current.characters.isNotEmpty,
          listener: (context, state) {
            if (!MediaQuery.disableAnimationsOf(context)) unawaited(_entrance.forward(from: 0));
          },
        ),
      ],
      child: Scaffold(
        body: NotificationListener<ScrollMetricsNotification>(
          onNotification: onScrollMetricsChanged,
          child: CustomScrollView(
            key: const PageStorageKey<String>('character-list'),
            controller: scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              CharacterListHeader(searchController: _searchController),
              BlocBuilder<CharactersBloc, CharactersState>(
                builder: (context, state) => CharacterListContent(
                  state: state,
                  entrance: _entrance,
                  onClearSearch: _clearSearch,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
