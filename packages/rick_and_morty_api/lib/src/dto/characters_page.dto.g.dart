// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'characters_page.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharactersPageDTO _$CharactersPageDTOFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CharactersPageDTO', json, ($checkedConvert) {
      final val = CharactersPageDTO(
        info: $checkedConvert(
          'info',
          (v) => PageInfoDTO.fromJson(v as Map<String, dynamic>),
        ),
        results: $checkedConvert(
          'results',
          (v) => (v as List<dynamic>)
              .map((e) => CharacterDTO.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });
