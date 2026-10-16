Map<String, dynamic> locationJson({
  String name = 'Earth (C-137)',
  String url = 'https://rickandmortyapi.com/api/location/1',
}) {
  return {'name': name, 'url': url};
}

Map<String, dynamic> characterJson({
  int id = 1,
  String name = 'Rick Sanchez',
  String status = 'Alive',
  String species = 'Human',
  String type = '',
  String gender = 'Male',
  Map<String, dynamic>? origin,
  Map<String, dynamic>? location,
}) {
  return {
    'id': id,
    'name': name,
    'status': status,
    'species': species,
    'type': type,
    'gender': gender,
    'origin': origin ?? locationJson(),
    'location':
        location ??
        locationJson(name: 'Citadel of Ricks', url: 'https://rickandmortyapi.com/api/location/3'),
    'image': 'https://rickandmortyapi.com/api/character/avatar/$id.jpeg',
    'episode': ['https://rickandmortyapi.com/api/episode/1'],
    'url': 'https://rickandmortyapi.com/api/character/$id',
    'created': '2017-11-04T18:48:46.250Z',
  };
}

Map<String, dynamic> pageInfoJson({
  int count = 826,
  int pages = 42,
  String? next = 'https://rickandmortyapi.com/api/character/?page=2',
}) {
  return {'count': count, 'pages': pages, 'next': next};
}

Map<String, dynamic> pageJson({
  List<Map<String, dynamic>>? results,
  String? next = 'https://rickandmortyapi.com/api/character/?page=2',
}) {
  return {
    'info': pageInfoJson(next: next),
    'results': results ?? [characterJson()],
  };
}
