part of 'accueil_bloc.dart';

/// Vue légère « humeur du jour » (état B).
///
/// L'emoji est mappé depuis [codeEmotion] ; le libellé est résolu via i18n.
@immutable
class HumeurDuJourVue {
  const HumeurDuJourVue({
    required this.codeEmotion,
    required this.emoji,
    required this.noteeLe,
  });

  /// Code stable de l'émotion (aligné `MoodColors.byKey`).
  final String codeEmotion;

  /// Emoji mappé en dur depuis [codeEmotion].
  final String emoji;

  /// Horodatage de la dernière entrée du jour.
  final DateTime noteeLe;

  @override
  bool operator ==(Object other) =>
      other is HumeurDuJourVue &&
      other.codeEmotion == codeEmotion &&
      other.emoji == emoji &&
      other.noteeLe == noteeLe;

  @override
  int get hashCode => Object.hash(codeEmotion, emoji, noteeLe);
}

/// Vue légère « conseil du jour ». Le texte est résolu via i18n d'après [cle].
@immutable
class ConseilDuJourVue {
  const ConseilDuJourVue({required this.cle});

  /// Clé i18n du conseil (`tipDay01`..`tipDay07`).
  final String cle;

  @override
  bool operator ==(Object other) =>
      other is ConseilDuJourVue && other.cle == cle;

  @override
  int get hashCode => cle.hashCode;
}

/// États de l'écran Accueil.
@immutable
sealed class AccueilState {
  const AccueilState();
}

/// Chargement initial (avant la 1re émission du stream Drift).
final class AccueilChargement extends AccueilState {
  const AccueilChargement();

  @override
  bool operator ==(Object other) => other is AccueilChargement;

  @override
  int get hashCode => (AccueilChargement).hashCode;
}

/// Écran prêt : [humeurDuJour] `null` → état A, non-`null` → état B.
final class AccueilPret extends AccueilState {
  const AccueilPret({required this.conseil, this.humeurDuJour});

  /// Humeur du jour (état B) ou `null` (état A).
  final HumeurDuJourVue? humeurDuJour;

  /// Conseil du jour à afficher.
  final ConseilDuJourVue conseil;

  @override
  bool operator ==(Object other) =>
      other is AccueilPret &&
      other.humeurDuJour == humeurDuJour &&
      other.conseil == conseil;

  @override
  int get hashCode => Object.hash(humeurDuJour, conseil);
}

/// Erreur de lecture Drift : l'UI rend l'état A en repli (pas de crash).
final class AccueilErreur extends AccueilState {
  const AccueilErreur();

  @override
  bool operator ==(Object other) => other is AccueilErreur;

  @override
  int get hashCode => (AccueilErreur).hashCode;
}
