part of 'demarrage_bloc.dart';

/// États du démarrage (splash). Machine à états transitoire (DEC-S).
@immutable
sealed class DemarrageState {
  const DemarrageState();
}

/// État de départ : rien n'est lancé.
@immutable
final class DemarrageInitial extends DemarrageState {
  const DemarrageInitial();

  @override
  bool operator ==(Object other) => other is DemarrageInitial;

  @override
  int get hashCode => (DemarrageInitial).hashCode;
}

/// Initialisation en cours (warm-up Drift) + chrono du délai minimal démarré.
@immutable
final class DemarrageEnCours extends DemarrageState {
  const DemarrageEnCours();

  @override
  bool operator ==(Object other) => other is DemarrageEnCours;

  @override
  int get hashCode => (DemarrageEnCours).hashCode;
}

/// Init terminée + délai écoulé, bienvenue **non vue** → route Bienvenue.
@immutable
final class DemarragePretPourBienvenue extends DemarrageState {
  const DemarragePretPourBienvenue();

  @override
  bool operator ==(Object other) => other is DemarragePretPourBienvenue;

  @override
  int get hashCode => (DemarragePretPourBienvenue).hashCode;
}

/// Init terminée + délai écoulé, bienvenue **déjà vue** → route Accueil.
@immutable
final class DemarragePretPourAccueil extends DemarrageState {
  const DemarragePretPourAccueil();

  @override
  bool operator ==(Object other) => other is DemarragePretPourAccueil;

  @override
  int get hashCode => (DemarragePretPourAccueil).hashCode;
}

/// Échec d'init (ex. ouverture Drift). L'app route **quand même** (§7) :
/// [versBienvenue] indique la cible déduite du flag bienvenue.
@immutable
final class DemarrageErreur extends DemarrageState {
  const DemarrageErreur({required this.versBienvenue});

  /// `true` → router vers Bienvenue, `false` → vers Accueil.
  final bool versBienvenue;

  @override
  bool operator ==(Object other) =>
      other is DemarrageErreur && other.versBienvenue == versBienvenue;

  @override
  int get hashCode => Object.hash(DemarrageErreur, versBienvenue);
}
