part of 'demarrage_bloc.dart';

/// Statut de la machine à états du démarrage (splash).
enum DemarrageStatus { initial, enCours, pret, erreur }

/// Extension de getters utilitaires sur [DemarrageStatus].
extension DemarrageStatusX on DemarrageStatus {
  /// `true` pendant l'initialisation Drift.
  bool get estEnCours => this == DemarrageStatus.enCours;

  /// `true` quand l'initialisation est terminée sans erreur.
  bool get estPret => this == DemarrageStatus.pret;

  /// `true` en cas d'erreur d'initialisation.
  bool get estEnErreur => this == DemarrageStatus.erreur;
}

/// États du démarrage (splash). Machine à états transitoire (DEC-S).
@immutable
sealed class DemarrageState extends Equatable {
  const DemarrageState();
}

/// État de départ : rien n'est lancé.
final class DemarrageInitial extends DemarrageState {
  const DemarrageInitial();

  @override
  List<Object?> get props => [];
}

/// Initialisation en cours (warm-up Drift) + chrono du délai minimal démarré.
final class DemarrageEnCours extends DemarrageState {
  const DemarrageEnCours();

  @override
  List<Object?> get props => [];
}

/// Init terminée + délai écoulé → route toujours vers l'Accueil.
///
/// L'onboarding (Bienvenue) est abandonné : le Demarrage route directement
/// vers l'Accueil quelle que soit l'historique d'utilisation (DEC-PROD-2026).
final class DemarragePret extends DemarrageState {
  const DemarragePret();

  @override
  List<Object?> get props => [];
}

/// Échec d'init (ex. ouverture Drift). L'app route **quand même** (§7)
/// vers l'Accueil — jamais vers Bienvenue (onboarding abandonné).
final class DemarrageErreur extends DemarrageState {
  const DemarrageErreur();

  @override
  List<Object?> get props => [];
}
