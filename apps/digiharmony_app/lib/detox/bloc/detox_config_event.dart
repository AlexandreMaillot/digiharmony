part of 'detox_config_bloc.dart';

/// Evenement du bloc de configuration Detox.
sealed class DetoxConfigEvent extends Equatable {
  const DetoxConfigEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Selectionne une ambiance.
class DetoxAmbianceSelectionnee extends DetoxConfigEvent {
  /// {@macro detox_ambiance_selectionnee}
  const DetoxAmbianceSelectionnee(this.id);

  /// Identifiant de l'ambiance choisie.
  final IdAmbianceDetox id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Selectionne une duree (en minutes).
class DetoxDureeSelectionnee extends DetoxConfigEvent {
  /// {@macro detox_duree_selectionnee}
  const DetoxDureeSelectionnee(this.minutes);

  /// Duree choisie en minutes.
  final int minutes;

  @override
  List<Object?> get props => <Object?>[minutes];
}
