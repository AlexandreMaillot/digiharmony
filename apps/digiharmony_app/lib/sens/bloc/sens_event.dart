part of 'sens_bloc.dart';

/// Evenement de la machine « Les sens ».
sealed class SensEvent extends Equatable {
  const SensEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Arrivee sur l'ecran : joue l'audio de la premiere etape.
class SensDemarree extends SensEvent {
  /// {@macro sens_demarree}
  const SensDemarree();
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
