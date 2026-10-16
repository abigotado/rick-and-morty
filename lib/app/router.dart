import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rick_and_morty/features/characters/details/character_details_page.dart';
import 'package:rick_and_morty/features/characters/list/character_list_page.dart';

// Pages are explicit: go_router looks for material_ui's MaterialApp, misses this one and would
// fall back to NoTransitionPage (no transition, no hero flight, no iOS back swipe).
GoRouter createRouter() => GoRouter(
  onException: (context, state, router) => router.go('/'),
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          MaterialPage<void>(key: state.pageKey, child: const CharacterListPage()),
      routes: [
        GoRoute(
          path: 'character/:id',
          redirect: (context, state) {
            final segment = state.pathParameters['id']!;
            // Radix 10 rejects hex; other decimal spellings (+1, 007) collapse to one URL.
            return switch (int.tryParse(segment, radix: 10)) {
              final id? when id > 0 && segment == '$id' => null,
              final id? when id > 0 => '/character/$id',
              _ => '/',
            };
          },
          pageBuilder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            final extra = state.extra;
            return MaterialPage<void>(
              // pageKey is per route pattern; a new id needs a new page (and cubit).
              key: ValueKey('/character/$id'),
              child: CharacterDetailsPage(
                characterId: id,
                character: extra is CharacterEntity && extra.id == id ? extra : null,
              ),
            );
          },
        ),
      ],
    ),
  ],
);
