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

/// Tick du ticker (200 ms) de la routine.
class EtirementTick extends EtirementEvent {
  /// {@macro etirement_tick}
  const EtirementTick();
}

/// Tick (1 s) du decompte de preparation (3 -> 2 -> 1 -> demarrage).
class EtirementTickPreparation extends EtirementEvent {
  /// {@macro etirement_tick_preparation}
  const EtirementTickPreparation();
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
