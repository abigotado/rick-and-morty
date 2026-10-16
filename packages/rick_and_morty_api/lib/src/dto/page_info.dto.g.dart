// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_info.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageInfoDTO _$PageInfoDTOFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PageInfoDTO', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['next']);
      final val = PageInfoDTO(
        count: $checkedConvert('count', (v) => (v as num).toInt()),
        pages: $checkedConvert('pages', (v) => (v as num).toInt()),
        next: $checkedConvert('next', (v) => v as String?),
      );
      return val;
    });
