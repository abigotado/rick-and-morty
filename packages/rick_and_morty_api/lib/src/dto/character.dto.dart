import 'package:json_annotation/json_annotation.dart';
import 'package:rick_and_morty_api/src/dto/location_ref.dto.dart';

part 'character.dto.g.dart';

@JsonSerializable()
class CharacterDTO {
  const CharacterDTO({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
  });

  factory CharacterDTO.fromJson(Map<String, dynamic> json) => _$CharacterDTOFromJson(json);

  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final LocationRefDTO origin;
  final LocationRefDTO location;
  final String image;
}
