part of 'detox_lecteur_bloc.dart';

/// Evenement du lecteur Detox.
sealed class DetoxLecteurEvent extends Equatable {
  const DetoxLecteurEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Demarrage auto (lecture + ticker).
class DetoxLecteurDemarre extends DetoxLecteurEvent {
  /// {@macro detox_lecteur_demarre}
  const DetoxLecteurDemarre();
}

/// Tick du minuteur.
class DetoxLecteurTick extends DetoxLecteurEvent {
  /// {@macro detox_lecteur_tick}
  const DetoxLecteurTick();
}

/// Sortie anticipee confirmee (stop audio, pas d'ecriture Drift).
class DetoxLecteurTermine extends DetoxLecteurEvent {
  /// {@macro detox_lecteur_termine}
  const DetoxLecteurTermine();
}
