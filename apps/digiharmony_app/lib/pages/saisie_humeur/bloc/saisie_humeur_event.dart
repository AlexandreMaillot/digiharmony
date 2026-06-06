part of 'saisie_humeur_bloc.dart';

/// Événements du bloc de saisie d'humeur.
sealed class SaisieHumeurEvent {
  const SaisieHumeurEvent();
}

/// L'utilisateur a tapé une pastille — sélection visuelle seule, aucune
/// écriture Drift (l'enregistrement n'a lieu qu'à la validation).
final class EmotionSelectionnee extends SaisieHumeurEvent {
  const EmotionSelectionnee(this.codeEmotion);

  /// Code stable de l'émotion sélectionnée.
  final String codeEmotion;
}

/// L'utilisateur a pressé « Valider » — déclenche l'UPSERT Drift puis le
/// retour à l'Accueil (géré côté View).
final class SaisieValidee extends SaisieHumeurEvent {
  const SaisieValidee();
}
