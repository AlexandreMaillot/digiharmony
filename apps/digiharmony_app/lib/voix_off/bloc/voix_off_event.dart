part of 'voix_off_bloc.dart';

/// Événement du [VoixOffBloc].
sealed class VoixOffEvent extends Equatable {
  const VoixOffEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Bascule l'état actif/inactif de la voix off.
class VoixOffBasculee extends VoixOffEvent {
  /// {@macro voix_off_basculee}
  const VoixOffBasculee();
}

/// Force l'état de la voix off à une valeur précise.
class VoixOffDefinie extends VoixOffEvent {
  /// {@macro voix_off_definie}
  const VoixOffDefinie({required this.active});

  /// Valeur cible.
  final bool active;

  @override
  List<Object?> get props => <Object?>[active];
}
