part of 'demarrage_bloc.dart';

/// Statut de la machine à états du démarrage (splash).
enum DemarrageStatus { initial, enCours, pretBienvenue, pretAccueil, erreur }

/// Extension de getters utilitaires sur [DemarrageStatus].
extension DemarrageStatusX on DemarrageStatus {
  /// `true` pendant l'initialisation Drift.
  bool get estEnCours => this == DemarrageStatus.enCours;

  /// `true` quand l'initialisation est terminée sans erreur.
  bool get estPret =>
      this == DemarrageStatus.pretBienvenue ||
      this == DemarrageStatus.pretAccueil;

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

/// Init terminée + délai écoulé, bienvenue **non vue** → route Bienvenue.
final class DemarragePretPourBienvenue extends DemarrageState {
  const DemarragePretPourBienvenue();

  @override
  List<Object?> get props => [];
}

/// Init terminée + délai écoulé, bienvenue **déjà vue** → route Accueil.
final class DemarragePretPourAccueil extends DemarrageState {
  const DemarragePretPourAccueil();

  @override
  List<Object?> get props => [];
}

/// Échec d'init (ex. ouverture Drift). L'app route **quand même** (§7) :
/// [versBienvenue] indique la cible déduite du flag bienvenue.
final class DemarrageErreur extends DemarrageState {
  const DemarrageErreur({required this.versBienvenue});

  /// `true` → router vers Bienvenue, `false` → vers Accueil.
  final bool versBienvenue;

  @override
  List<Object?> get props => [versBienvenue];
}
