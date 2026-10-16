import 'package:characters_domain/src/entities/character.entity.dart';
import 'package:equatable/equatable.dart';

class CharactersPageEntity extends Equatable {
  const CharactersPageEntity({required this.characters, required this.totalCount, this.nextPage});

  const CharactersPageEntity.empty() : characters = const [], totalCount = 0, nextPage = null;

  final List<CharacterEntity> characters;
  final int totalCount;
  final int? nextPage;

  @override
  List<Object?> get props => [characters, totalCount, nextPage];
}
