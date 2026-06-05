part of 'saisie_humeur_bloc.dart';

/// Événements du bloc de saisie d'humeur.
sealed class SaisieHumeurEvent {
  const SaisieHumeurEvent();
}

/// L'utilisateur a tapé sur une pastille d'émotion.
final class EmotionTapee extends SaisieHumeurEvent {
  const EmotionTapee(this.codeEmotion);

  /// Code stable de l'émotion sélectionnée.
  final String codeEmotion;
}

/// L'utilisateur a pressé « Annuler » dans le snackbar de confirmation.
final class SaisieAnnulee extends SaisieHumeurEvent {
  const SaisieAnnulee();
}

/// La fenêtre d'annulation a expiré (gérée côté View via SnackBar).
final class FenetreUndoExpiree extends SaisieHumeurEvent {
  const FenetreUndoExpiree();
}
