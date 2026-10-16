import 'package:json_annotation/json_annotation.dart';

part 'page_info.dto.g.dart';

@JsonSerializable()
class PageInfoDTO {
  const PageInfoDTO({required this.count, required this.pages, this.next});

  factory PageInfoDTO.fromJson(Map<String, dynamic> json) => _$PageInfoDTOFromJson(json);

  final int count;
  final int pages;
  @JsonKey(required: true)
  final String? next;
}
