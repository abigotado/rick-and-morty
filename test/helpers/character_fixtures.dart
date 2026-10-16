import 'package:characters_domain/characters_domain.dart';

final rick = CharacterEntity(
  id: 1,
  name: 'Rick Sanchez',
  status: CharacterStatus.alive,
  species: 'Human',
  type: '',
  gender: 'Male',
  origin: 'Earth (C-137)',
  location: 'Citadel of Ricks',
  imageUrl: Uri.parse('https://rickandmortyapi.com/api/character/avatar/1.jpeg'),
);

CharacterEntity buildCharacter(
  int id, {
  String? name,
  CharacterStatus status = CharacterStatus.alive,
}) {
  return CharacterEntity(
    id: id,
    name: name ?? 'Character $id',
    status: status,
    species: 'Human',
    type: '',
    gender: 'Male',
    origin: 'Earth (C-137)',
    location: 'Citadel of Ricks',
    imageUrl: Uri.parse('https://rickandmortyapi.com/api/character/avatar/$id.jpeg'),
  );
}
