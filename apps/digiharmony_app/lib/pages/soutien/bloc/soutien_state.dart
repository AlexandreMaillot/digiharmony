part of 'soutien_bloc.dart';

/// État léger persistant de l'anti-relance (DEC-003).
///
/// [dejaMontrePourEpisodeEnCours] : true tant que le compteur n'est pas
/// redescendu sous 7. Empêche de re-montrer le même épisode.
final class SoutienState extends Equatable {
  /// Crée l'état.
  ///
  /// [dejaMontrePourEpisodeEnCours] `false` = soutien jamais montré
  /// pour l'épisode courant.
  const SoutienState({this.dejaMontrePourEpisodeEnCours = false});

  /// Indique si le soutien a déjà été montré pour l'épisode en cours.
  final bool dejaMontrePourEpisodeEnCours;

  /// Retourne une copie avec les champs modifiés.
  SoutienState copyWith({bool? dejaMontrePourEpisodeEnCours}) {
    return SoutienState(
      dejaMontrePourEpisodeEnCours:
          dejaMontrePourEpisodeEnCours ?? this.dejaMontrePourEpisodeEnCours,
    );
  }

  @override
  List<Object?> get props => [dejaMontrePourEpisodeEnCours];
}
