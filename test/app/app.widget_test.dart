import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty/app/app.dart';
import 'package:rick_and_morty/app/theme.dart';
import 'package:rick_and_morty/features/characters/domain/characters_page.dart';
import 'package:rick_and_morty/features/characters/domain/characters_repository.dart';
import 'package:rick_and_morty/features/characters/presentation/list/character_list_page.dart';

class MockCharactersRepository extends Mock implements CharactersRepository {}

void main() {
  late MockCharactersRepository repository;

  setUp(() {
    repository = MockCharactersRepository();
    when(
      () => repository.getCharacters(
        page: any(named: 'page'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => const CharactersPage.empty());
  });

  Future<void> pumpApp(WidgetTester tester) {
    return tester.pumpWidget(
      RepositoryProvider<CharactersRepository>.value(
        value: repository,
        child: const App(),
      ),
    );
  }

  group('App', () {
    testWidgets('uses light and dark themes', (tester) async {
      await pumpApp(tester);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme, AppTheme.light);
      expect(app.darkTheme, AppTheme.dark);
    });

    testWidgets('opens on the character list', (tester) async {
      await pumpApp(tester);
      await tester.pump();

      expect(find.byType(CharacterListPage), findsOneWidget);
      verify(() => repository.getCharacters()).called(1);
    });
  });
}
