import 'package:rick_and_morty/features/characters/domain/character.dart';

Map<String, dynamic> characterJson({
  int id = 1,
  String name = 'Rick Sanchez',
  String status = 'Alive',
  String species = 'Human',
  String type = '',
  String gender = 'Male',
  String originName = 'Earth (C-137)',
  String originUrl = 'https://rickandmortyapi.com/api/location/1',
  String locationName = 'Citadel of Ricks',
  String locationUrl = 'https://rickandmortyapi.com/api/location/3',
  String? image,
}) {
  return {
    'id': id,
    'name': name,
    'status': status,
    'species': species,
    'type': type,
    'gender': gender,
    'origin': {'name': originName, 'url': originUrl},
    'location': {'name': locationName, 'url': locationUrl},
    'image': image ?? 'https://rickandmortyapi.com/api/character/avatar/$id.jpeg',
    'episode': ['https://rickandmortyapi.com/api/episode/1'],
    'url': 'https://rickandmortyapi.com/api/character/$id',
    'created': '2017-11-04T18:48:46.250Z',
  };
}

Map<String, dynamic> pageJson({
  List<Map<String, dynamic>>? results,
  String? next = 'https://rickandmortyapi.com/api/character/?page=2',
  String? prev,
}) {
  final items = results ?? [characterJson()];
  return {
    'info': {'count': items.length, 'pages': 2, 'next': next, 'prev': prev},
    'results': items,
  };
}

const rick = Character(
  id: 1,
  name: 'Rick Sanchez',
  status: CharacterStatus.alive,
  species: 'Human',
  type: '',
  gender: 'Male',
  origin: 'Earth (C-137)',
  location: 'Citadel of Ricks',
  imageUrl: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
);

Character buildCharacter(
  int id, {
  String? name,
  CharacterStatus status = CharacterStatus.alive,
}) {
  return Character(
    id: id,
    name: name ?? 'Character $id',
    status: status,
    species: 'Human',
    type: '',
    gender: 'Male',
    origin: 'Earth (C-137)',
    location: 'Citadel of Ricks',
    imageUrl: 'https://rickandmortyapi.com/api/character/avatar/$id.jpeg',
  );
}
