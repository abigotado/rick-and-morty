import 'package:go_router/go_router.dart';
import 'package:rick_and_morty/features/characters/presentation/list/character_list_page.dart';

GoRouter createRouter() => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CharacterListPage(),
    ),
  ],
);
