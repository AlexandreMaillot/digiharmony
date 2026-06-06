part of 'saisie_humeur_bloc.dart';

/// Événements du bloc de saisie d'humeur.
sealed class SaisieHumeurEvent {
  const SaisieHumeurEvent();
}

/// Ouverture de l'écran — pré-sélectionne l'humeur déjà notée aujourd'hui
/// (édition) si elle existe ; sinon reste à l'état initial.
final class SaisieDemarree extends SaisieHumeurEvent {
  const SaisieDemarree();
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
