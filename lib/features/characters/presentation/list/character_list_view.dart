import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/list/bloc/characters_bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/list/widgets/character_list_content.dart';

class CharacterListView extends StatefulWidget {
  const CharacterListView({super.key});

  @override
  State<CharacterListView> createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView> {
  static const _loadMoreThreshold = 300.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreIfNearEnd);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMoreIfNearEnd());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreIfNearEnd() {
    if (!mounted || !_scrollController.hasClients) return;
    final bloc = context.read<CharactersBloc>();
    if (!_canLoadMore(bloc.state)) return;
    if (_scrollController.position.extentAfter < _loadMoreThreshold) {
      bloc.add(const CharactersNextPageRequested());
    }
  }

  bool _canLoadMore(CharactersState state) =>
      state.status == CharactersStatus.success &&
      state.hasMore &&
      state.nextPageStatus == NextPageStatus.idle;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CharactersBloc, CharactersState>(
      listenWhen: (previous, current) =>
          _canLoadMore(current) &&
          (previous.status != current.status || previous.characters != current.characters),
      // A page that does not fill the viewport never produces a scroll event.
      listener: (context, state) =>
          WidgetsBinding.instance.addPostFrameCallback((_) => _loadMoreIfNearEnd()),
      child: Scaffold(
        body: NotificationListener<ScrollMetricsNotification>(
          onNotification: (notification) {
            _loadMoreIfNearEnd();
            return false;
          },
          child: CustomScrollView(
            key: const PageStorageKey<String>('character-list'),
            controller: _scrollController,
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
