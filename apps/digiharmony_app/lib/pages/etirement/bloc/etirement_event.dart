part of 'etirement_bloc.dart';

/// Evenement de la machine d'etirement.
sealed class EtirementEvent extends Equatable {
  const EtirementEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Demarrage auto (segment 0, ticker arme).
class EtirementDemarre extends EtirementEvent {
  /// {@macro etirement_demarre}
  const EtirementDemarre();
}

/// Tick du ticker.
class EtirementTick extends EtirementEvent {
  /// {@macro etirement_tick}
  const EtirementTick();
}

/// Bascule pause/reprise (tap sur le guide).
class EtirementPauseBasculee extends EtirementEvent {
  /// {@macro etirement_pause_basculee}
  const EtirementPauseBasculee();
}

/// Force la pause (sortie de seance).
class EtirementMisEnPause extends EtirementEvent {
  /// {@macro etirement_mis_en_pause}
  const EtirementMisEnPause();
}

/// Reinitialise la routine (Recommencer).
class EtirementRedemarree extends EtirementEvent {
  /// {@macro etirement_redemarree}
  const EtirementRedemarree();
}
