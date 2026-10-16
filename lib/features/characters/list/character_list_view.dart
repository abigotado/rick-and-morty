import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/core/pagination/infinite_scroll_mixin.dart';
import 'package:rick_and_morty/features/characters/list/bloc/characters_bloc.dart';
import 'package:rick_and_morty/features/characters/list/widgets/character_list_content.dart';

class CharacterListView extends StatefulWidget {
  const CharacterListView({super.key});

  @override
  State<CharacterListView> createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView> with InfiniteScrollMixin {
  @override
  bool get canLoadMore => context.read<CharactersBloc>().state.canLoadMore;

  @override
  void onLoadMore() => context.read<CharactersBloc>().add(const CharactersNextPageRequested());

  @override
  Widget build(BuildContext context) {
    return BlocListener<CharactersBloc, CharactersState>(
      listenWhen: (previous, current) =>
          current.canLoadMore &&
          (previous.status != current.status || previous.characters != current.characters),
      listener: (context, state) => scheduleLoadMoreCheck(),
      child: Scaffold(
        body: NotificationListener<ScrollMetricsNotification>(
          onNotification: onScrollMetricsChanged,
          child: CustomScrollView(
            key: const PageStorageKey<String>('character-list'),
            controller: scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              const SliverAppBar.large(title: Text('Characters')),
              BlocBuilder<CharactersBloc, CharactersState>(
                builder: (context, state) => CharacterListContent(state: state),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
