import 'package:characters_data/characters_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rick_and_morty/app/app.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/space_grotesk/OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['Space Grotesk'], license);
  });
  final service = CharactersService(createApiDio(logRequests: kDebugMode));
  runApp(App(charactersRepository: CharactersRepository(service)));
}
