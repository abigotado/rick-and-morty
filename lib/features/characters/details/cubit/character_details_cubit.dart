import 'package:characters_domain/characters_domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'character_details_state.dart';

class CharacterDetailsCubit extends Cubit<CharacterDetailsState> {
  CharacterDetailsCubit({
    required ICharactersRepository charactersRepository,
    required this.characterId,
    CharacterEntity? initialCharacter,
  }) : _repository = charactersRepository,
       super(
         switch (initialCharacter) {
           final character? => CharacterDetailsLoaded(character),
           null => const CharacterDetailsLoading(),
         },
       );

  final ICharactersRepository _repository;
  final int characterId;
  bool _inFlight = false;

  Future<void> load() async {
    if (state is CharacterDetailsLoaded || _inFlight) return;
    _inFlight = true;
    emit(const CharacterDetailsLoading());
    try {
      final character = await _repository.getCharacter(characterId);
      if (isClosed) return;
      emit(CharacterDetailsLoaded(character));
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(CharacterDetailsFailed(failure));
    } finally {
      _inFlight = false;
    }
  }
}
