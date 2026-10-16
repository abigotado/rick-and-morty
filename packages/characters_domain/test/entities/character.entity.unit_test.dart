import 'package:characters_domain/characters_domain.dart';
import 'package:test/test.dart';

CharacterEntity _character({
  int id = 1,
  String name = 'Rick Sanchez',
  CharacterStatus status = CharacterStatus.alive,
  String species = 'Human',
  String type = '',
  String gender = 'Male',
  String origin = 'Earth (C-137)',
  String location = 'Citadel of Ricks',
  String imageUrl = 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
}) {
  return CharacterEntity(
    id: id,
    name: name,
    status: status,
    species: species,
    type: type,
    gender: gender,
    origin: origin,
    location: location,
    imageUrl: Uri.parse(imageUrl),
  );
}

void main() {
  group('CharacterEntity', () {
    group('==', () {
      test('same fields → equal', () {
        expect(_character(), _character());
      });

      final variants = <String, CharacterEntity>{
        'id': _character(id: 2),
        'name': _character(name: 'Morty Smith'),
        'status': _character(status: CharacterStatus.dead),
        'species': _character(species: 'Alien'),
        'type': _character(type: 'Parasite'),
        'gender': _character(gender: 'Female'),
        'origin': _character(origin: 'unknown'),
        'location': _character(location: 'unknown'),
        'imageUrl': _character(imageUrl: 'https://example.com/2.jpeg'),
      };
      for (final MapEntry(key: field, value: other) in variants.entries) {
        test('different $field → not equal', () {
          expect(other, isNot(_character()));
        });
      }
    });
  });
}
