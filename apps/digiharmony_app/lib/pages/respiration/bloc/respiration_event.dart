part of 'respiration_bloc.dart';

/// Evenement de la machine de respiration.
sealed class RespirationEvent extends Equatable {
  const RespirationEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Demarrage (auto a l'ouverture) : lance le decompte de preparation.
class RespirationDemarree extends RespirationEvent {
  /// {@macro respiration_demarree}
  const RespirationDemarree();
}

/// Tick (1 s) du decompte de preparation (3 -> 2 -> 1 -> demarrage).
class RespirationTickPreparation extends RespirationEvent {
  /// {@macro respiration_tick_preparation}
  const RespirationTickPreparation();
}

/// Fin de la phase courante (emis par le ticker interne).
class RespirationTick extends RespirationEvent {
  /// {@macro respiration_tick}
  const RespirationTick();
}

/// Bascule pause/reprise (tap sur la bulle).
class RespirationPauseBasculee extends RespirationEvent {
  /// {@macro respiration_pause_basculee}
  const RespirationPauseBasculee();
}

/// Force la pause (sortie de seance).
class RespirationMiseEnPause extends RespirationEvent {
  /// {@macro respiration_mise_en_pause}
  const RespirationMiseEnPause();
}

/// Reinitialise la seance (Recommencer).
class RespirationRedemarree extends RespirationEvent {
  /// {@macro respiration_redemarree}
  const RespirationRedemarree();
}
