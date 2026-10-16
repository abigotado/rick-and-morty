import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:rick_and_morty_api/src/dto/dto.dart';

part 'characters.api.g.dart';

@RestApi()
abstract class CharactersApi {
  factory CharactersApi(Dio dio) = _CharactersApi;

  @GET('/character/')
  Future<CharactersPageDTO?> getCharacters(
    @Query('page') int page, {
    @Query('name') String? name,
  });

  @GET('/character/{id}')
  Future<CharacterDTO?> getCharacter(@Path('id') int id);
}
