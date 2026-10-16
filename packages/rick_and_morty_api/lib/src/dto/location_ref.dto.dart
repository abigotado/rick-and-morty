import 'package:json_annotation/json_annotation.dart';

part 'location_ref.dto.g.dart';

@JsonSerializable()
class LocationRefDTO {
  const LocationRefDTO({required this.name, required this.url});

  factory LocationRefDTO.fromJson(Map<String, dynamic> json) => _$LocationRefDTOFromJson(json);

  final String name;
  final String url;
}
