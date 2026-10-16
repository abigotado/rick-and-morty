import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty/app/app.dart';
import 'package:rick_and_morty/app/theme.dart';
import 'package:rick_and_morty/features/characters/list/character_list_page.dart';
import 'package:rick_and_morty/features/characters/list/character_list_view.dart';

class _MockCharactersRepository extends Mock implements ICharactersRepository {}

void main() {
  late _MockCharactersRepository repository;

  setUp(() {
    repository = _MockCharactersRepository();
    when(
      () => repository.getCharacters(
        page: any(named: 'page'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => const CharactersPageEntity.empty());
  });

  group('App', () {
    testWidgets('dark-only design → dark theme and no separate light/dark pair', (tester) async {
      await tester.pumpWidget(App(charactersRepository: repository));

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme, AppTheme.dark);
      expect(app.darkTheme, isNull);
    });

    testWidgets('opens on the character list and loads the first page', (tester) async {
      await tester.pumpWidget(App(charactersRepository: repository));
      await tester.pump();

      expect(find.byType(CharacterListPage), findsOneWidget);
      expect(find.byType(CharacterListView), findsOneWidget);
      expect(find.text('No characters found'), findsOneWidget);
      verify(() => repository.getCharacters()).called(1);
    });
  });
}
