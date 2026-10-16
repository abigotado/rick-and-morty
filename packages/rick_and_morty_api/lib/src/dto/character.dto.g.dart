// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterDTO _$CharacterDTOFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CharacterDTO', json, ($checkedConvert) {
      final val = CharacterDTO(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        status: $checkedConvert('status', (v) => v as String),
        species: $checkedConvert('species', (v) => v as String),
        type: $checkedConvert('type', (v) => v as String),
        gender: $checkedConvert('gender', (v) => v as String),
        origin: $checkedConvert(
          'origin',
          (v) => LocationRefDTO.fromJson(v as Map<String, dynamic>),
        ),
        location: $checkedConvert(
          'location',
          (v) => LocationRefDTO.fromJson(v as Map<String, dynamic>),
        ),
        image: $checkedConvert('image', (v) => v as String),
      );
      return val;
    });
