part of 'temps_ecran_bloc.dart';

/// Statuts de l'écran « Mon temps d'écran ».
enum TempsEcranStatus {
  /// Avant le premier événement (transitoire).
  initial,

  /// Lecture native en cours.
  chargement,

  /// Android, accès aux statistiques non accordé.
  permissionRequise,

  /// Données disponibles et agrégées.
  pret,

  /// Accès OK mais aucune donnée sur la fenêtre.
  vide,

  /// Plateforme non supportée (iOS) — état dégradé bienveillant.
  indisponible,

  /// Exception lors de la lecture native / agrégation.
  erreur,
}

/// Entrée de l'historique hebdomadaire (un jour = une barre dans le graphe).
///
/// [jour] est normalisé à minuit local ; [total] peut être [Duration.zero]
/// si aucune donnée n'est disponible pour ce jour.
final class EntreeHistorique extends Equatable {
  /// Crée une entrée d'historique.
  const EntreeHistorique({required this.jour, required this.total});

  /// Date normalisée (minuit local).
  final DateTime jour;

  /// Total du temps d'écran ce jour-là.
  final Duration total;

  @override
  List<Object?> get props => [jour, total];
}

/// État de l'écran « Mon temps d'écran ».
final class TempsEcranState extends Equatable {
  /// Crée un état.
  const TempsEcranState({
    this.status = TempsEcranStatus.initial,
    this.resume,
    this.historique = const [],
  });

  /// Statut courant.
  final TempsEcranStatus status;

  /// Résumé agrégé (non-null uniquement en [TempsEcranStatus.pret]).
  final ResumeTempsEcran? resume;

  /// Historique des 7 derniers jours (vide si première utilisation).
  ///
  /// Toujours 7 entrées une fois chargé (jours manquants = Duration.zero).
  final List<EntreeHistorique> historique;

  /// Copie avec champs modifiés.
  TempsEcranState copierAvec({
    TempsEcranStatus? status,
    ResumeTempsEcran? resume,
    List<EntreeHistorique>? historique,
  }) {
    return TempsEcranState(
      status: status ?? this.status,
      resume: resume ?? this.resume,
      historique: historique ?? this.historique,
    );
  }

  @override
  List<Object?> get props => [status, resume, historique];
}
