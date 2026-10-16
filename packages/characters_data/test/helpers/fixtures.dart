import 'package:characters_domain/characters_domain.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';

CharacterDTO characterDto({
  int id = 1,
  String name = 'Rick Sanchez',
  String status = 'Alive',
  String type = '',
  LocationRefDTO origin = const LocationRefDTO(
    name: 'Earth (C-137)',
    url: 'https://rickandmortyapi.com/api/location/1',
  ),
  LocationRefDTO location = const LocationRefDTO(
    name: 'Citadel of Ricks',
    url: 'https://rickandmortyapi.com/api/location/3',
  ),
  String? image,
}) {
  return CharacterDTO(
    id: id,
    name: name,
    status: status,
    species: 'Human',
    type: type,
    gender: 'Male',
    origin: origin,
    location: location,
    image: image ?? 'https://rickandmortyapi.com/api/character/avatar/$id.jpeg',
  );
}

CharactersPageDTO pageDto({
  List<CharacterDTO>? results,
  String? next = 'https://rickandmortyapi.com/api/character/?page=2',
}) {
  return CharactersPageDTO(
    info: PageInfoDTO(count: 826, pages: 42, next: next),
    results: results ?? [characterDto()],
  );
}

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
