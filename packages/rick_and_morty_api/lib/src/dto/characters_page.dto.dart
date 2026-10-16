import 'package:json_annotation/json_annotation.dart';
import 'package:rick_and_morty_api/src/dto/character.dto.dart';
import 'package:rick_and_morty_api/src/dto/page_info.dto.dart';

part 'characters_page.dto.g.dart';

@JsonSerializable()
class CharactersPageDTO {
  const CharactersPageDTO({required this.info, required this.results});

  factory CharactersPageDTO.fromJson(Map<String, dynamic> json) =>
      _$CharactersPageDTOFromJson(json);

  final PageInfoDTO info;
  final List<CharacterDTO> results;
}
