part of 'accueil_bloc.dart';

/// Vue légère « humeur du jour » (état B).
///
/// L'emoji est mappé depuis [codeEmotion] ; le libellé est résolu via i18n.
@immutable
final class HumeurDuJourVue extends Equatable {
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
  List<Object?> get props => [codeEmotion, emoji, noteeLe];
}

/// Vue légère « conseil du jour ». Le texte est résolu via i18n d'après [cle].
@immutable
final class ConseilDuJourVue extends Equatable {
  const ConseilDuJourVue({required this.cle});

  /// Clé i18n du conseil (`tipDay01`..`tipDay07`).
  final String cle;

  @override
  List<Object?> get props => [cle];
}

/// Statut de l'écran Accueil.
enum AccueilStatus { chargement, pret, erreur }

/// Extension de getters utilitaires sur [AccueilStatus].
extension AccueilStatusX on AccueilStatus {
  /// `true` pendant le chargement initial.
  bool get estEnChargement => this == AccueilStatus.chargement;

  /// `true` quand les données sont disponibles.
  bool get estSucces => this == AccueilStatus.pret;

  /// `true` en cas d'erreur de lecture Drift.
  bool get estEnErreur => this == AccueilStatus.erreur;
}

/// États de l'écran Accueil.
@immutable
sealed class AccueilState extends Equatable {
  const AccueilState();
}

/// Chargement initial (avant la 1re émission du stream Drift).
final class AccueilChargement extends AccueilState {
  const AccueilChargement();

  @override
  List<Object?> get props => [];
}

/// Écran prêt : [humeurDuJour] `null` → état A, non-`null` → état B.
final class AccueilPret extends AccueilState {
  const AccueilPret({required this.conseil, this.humeurDuJour});

  /// Humeur du jour (état B) ou `null` (état A).
  final HumeurDuJourVue? humeurDuJour;

  /// Conseil du jour à afficher.
  final ConseilDuJourVue conseil;

  @override
  List<Object?> get props => [conseil, humeurDuJour];
}

/// Erreur de lecture Drift : l'UI rend l'état A en repli (pas de crash).
final class AccueilErreur extends AccueilState {
  const AccueilErreur();

  @override
  List<Object?> get props => [];
}
