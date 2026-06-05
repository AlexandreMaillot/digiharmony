part of 'saisie_humeur_bloc.dart';

/// États du bloc de saisie d'humeur.
sealed class SaisieHumeurState extends Equatable {
  const SaisieHumeurState();

  @override
  List<Object?> get props => [];
}

/// Aucun tap encore — écran initial.
final class SaisieInitiale extends SaisieHumeurState {
  const SaisieInitiale();
}

/// Tap reçu, UPSERT en vol.
final class EnregistrementEnCours extends SaisieHumeurState {
  const EnregistrementEnCours({
    required this.codeEmotion,
    this.ancienneEntree,
  });

  final String codeEmotion;

  /// Entrée précédente du jour avant écrasement (null si première saisie).
  final EntreeHumeur? ancienneEntree;

  @override
  List<Object?> get props => [codeEmotion, ancienneEntree];
}

/// UPSERT OK — fenêtre d'annulation ouverte (~5 s).
final class EnregistrementReussi extends SaisieHumeurState {
  const EnregistrementReussi({
    required this.codeEmotion,
    this.ancienneEntree,
  });

  final String codeEmotion;

  /// Entrée précédente (pour restauration si annulation).
  final EntreeHumeur? ancienneEntree;

  @override
  List<Object?> get props => [codeEmotion, ancienneEntree];
}

/// Annulation effectuée — l'ancienne valeur a été restaurée ou supprimée.
final class SaisieAnnuleeEtat extends SaisieHumeurState {
  const SaisieAnnuleeEtat({this.codeEmotionRestauree});

  /// Code de l'émotion restaurée, null si suppression (première saisie).
  final String? codeEmotionRestauree;

  @override
  List<Object?> get props => [codeEmotionRestauree];
}

/// Exception Drift lors de l'UPSERT ou de l'annulation.
final class EnregistrementEchoue extends SaisieHumeurState {
  const EnregistrementEchoue({
    required this.codeEmotion,
    required this.message,
  });

  final String codeEmotion;
  final String message;

  @override
  List<Object?> get props => [codeEmotion, message];
}
