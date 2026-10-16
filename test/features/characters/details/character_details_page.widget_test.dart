import 'package:characters_domain/characters_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty/app/theme.dart';
import 'package:rick_and_morty/features/characters/details/character_details_page.dart';

import '../../../helpers/character_fixtures.dart';

class MockCharactersRepository extends Mock implements ICharactersRepository {}

void main() {
  late MockCharactersRepository repository;

  setUp(() {
    repository = MockCharactersRepository();
  });

  Future<void> pumpPage(WidgetTester tester, CharacterDetailsPage page) async {
    await tester.pumpWidget(
      RepositoryProvider<ICharactersRepository>.value(
        value: repository,
        child: MaterialApp(theme: AppTheme.dark, home: page),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  group('CharacterDetailsPage', () {
    group('build', () {
      testWidgets('character passed → shown without a request', (tester) async {
        await pumpPage(tester, CharacterDetailsPage(characterId: rick.id, character: rick));

        expect(find.text('Rick Sanchez'), findsOneWidget);
        verifyNever(() => repository.getCharacter(any()));
      });

      testWidgets('only an id → loads the character by id and shows it', (tester) async {
        when(() => repository.getCharacter(7)).thenAnswer((_) async => buildCharacter(7));

        await pumpPage(tester, const CharacterDetailsPage(characterId: 7));

        expect(find.text('Character 7'), findsOneWidget);
        verify(() => repository.getCharacter(7)).called(1);
      });
    });
  });
}
