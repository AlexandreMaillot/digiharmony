part of 'saisie_humeur_bloc.dart';

/// États du bloc de saisie d'humeur.
sealed class SaisieHumeurState extends Equatable {
  const SaisieHumeurState();

  /// Code de l'émotion actuellement retenue (sélectionnée, en cours ou
  /// échouée), ou `null` à l'état initial. Sert à activer le bouton Valider.
  String? get codeSelectionne => null;

  @override
  List<Object?> get props => [];
}

/// Aucune émotion sélectionnée — écran initial.
final class SaisieInitiale extends SaisieHumeurState {
  const SaisieInitiale();
}

/// Une émotion est sélectionnée, en attente de validation (aucune écriture).
final class EmotionSelectionneeEtat extends SaisieHumeurState {
  const EmotionSelectionneeEtat(this.codeEmotion);

  final String codeEmotion;

  @override
  String? get codeSelectionne => codeEmotion;

  @override
  List<Object?> get props => [codeEmotion];
}

/// Validation pressée, UPSERT Drift en vol.
final class EnregistrementEnCours extends SaisieHumeurState {
  const EnregistrementEnCours({required this.codeEmotion});

  final String codeEmotion;

  @override
  String? get codeSelectionne => codeEmotion;

  @override
  List<Object?> get props => [codeEmotion];
}

/// UPSERT OK — la View referme l'écran et revient à l'Accueil.
final class EnregistrementReussi extends SaisieHumeurState {
  const EnregistrementReussi({required this.codeEmotion});

  final String codeEmotion;

  @override
  String? get codeSelectionne => codeEmotion;

  @override
  List<Object?> get props => [codeEmotion];
}

/// Exception Drift lors de l'UPSERT — la sélection est conservée pour
/// réessayer.
final class EnregistrementEchoue extends SaisieHumeurState {
  const EnregistrementEchoue({
    required this.codeEmotion,
    required this.message,
  });

  final String codeEmotion;
  final String message;

  @override
  String? get codeSelectionne => codeEmotion;

  @override
  List<Object?> get props => [codeEmotion, message];
}
