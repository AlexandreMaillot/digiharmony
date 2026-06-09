part of 'sens_bloc.dart';

/// Evenement de la machine « Les sens ».
sealed class SensEvent extends Equatable {
  const SensEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Arrivee sur l'ecran : lance le decompte de preparation.
class SensDemarree extends SensEvent {
  /// {@macro sens_demarree}
  const SensDemarree();
}

/// Tick (1 s) du decompte de preparation (3 -> 2 -> 1 -> demarrage).
class SensTickPreparation extends SensEvent {
  /// {@macro sens_tick_preparation}
  const SensTickPreparation();
}

/// Bouton « Suivant ».
class SensSuivantPresse extends SensEvent {
  /// {@macro sens_suivant_presse}
  const SensSuivantPresse();
}

/// Bouton « Precedent ».
class SensPrecedentPresse extends SensEvent {
  /// {@macro sens_precedent_presse}
  const SensPrecedentPresse();
}

/// Bouton « Recommencer ».
class SensRedemarree extends SensEvent {
  /// {@macro sens_redemarree}
  const SensRedemarree();
}
