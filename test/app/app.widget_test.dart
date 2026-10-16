import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/app/app.dart';
import 'package:rick_and_morty/app/theme.dart';

void main() {
  group('App', () {
    testWidgets('uses light and dark themes', (tester) async {
      await tester.pumpWidget(const App());

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme, AppTheme.light);
      expect(app.darkTheme, AppTheme.dark);
    });
  });
}
