import 'package:characters_domain/src/entities/character.entity.dart';
import 'package:equatable/equatable.dart';

class CharactersPageEntity extends Equatable {
  const CharactersPageEntity({required this.characters, this.nextPage});

  const CharactersPageEntity.empty() : characters = const [], nextPage = null;

  final List<CharacterEntity> characters;
  final int? nextPage;

  @override
  List<Object?> get props => [characters, nextPage];
}
