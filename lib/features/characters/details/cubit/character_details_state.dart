part of 'character_details_cubit.dart';

sealed class CharacterDetailsState extends Equatable {
  const CharacterDetailsState();

  @override
  List<Object?> get props => [];
}

final class CharacterDetailsLoading extends CharacterDetailsState {
  const CharacterDetailsLoading();
}

final class CharacterDetailsLoaded extends CharacterDetailsState {
  const CharacterDetailsLoaded(this.character);

  final CharacterEntity character;

  @override
  List<Object?> get props => [character];
}

final class CharacterDetailsFailed extends CharacterDetailsState {
  const CharacterDetailsFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
