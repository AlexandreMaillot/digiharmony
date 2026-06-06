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

/// État de l'écran « Mon temps d'écran ».
final class TempsEcranState extends Equatable {
  /// Crée un état.
  const TempsEcranState({
    this.status = TempsEcranStatus.initial,
    this.resume,
  });

  /// Statut courant.
  final TempsEcranStatus status;

  /// Résumé agrégé (non-null uniquement en [TempsEcranStatus.pret]).
  final ResumeTempsEcran? resume;

  /// Copie avec champs modifiés.
  TempsEcranState copierAvec({
    TempsEcranStatus? status,
    ResumeTempsEcran? resume,
  }) {
    return TempsEcranState(
      status: status ?? this.status,
      resume: resume ?? this.resume,
    );
  }

  @override
  List<Object?> get props => [status, resume];
}
