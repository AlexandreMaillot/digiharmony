part of 'temps_ecran_bloc.dart';

/// Événements de l'écran « Mon temps d'écran ».
sealed class TempsEcranEvent extends Equatable {
  const TempsEcranEvent();

  @override
  List<Object?> get props => [];
}

/// Ouverture de la page : vérifie plateforme + accès, lit l'usage.
final class TempsEcranDemarre extends TempsEcranEvent {
  /// Crée l'événement de démarrage.
  const TempsEcranDemarre();
}

/// Tap sur le CTA « Activer l'accès » → ouvre les réglages système.
final class TempsEcranPermissionDemandee extends TempsEcranEvent {
  /// Crée l'événement de demande de permission.
  const TempsEcranPermissionDemandee();
}

/// Retour de l'app au premier plan (après les réglages système).
///
/// Relance la séquence pour basculer `permissionRequise → pret/vide` sans
/// refresh manuel (DEC-TE-07).
final class TempsEcranRevenuAuPremierPlan extends TempsEcranEvent {
  /// Crée l'événement de retour au premier plan.
  const TempsEcranRevenuAuPremierPlan();
}

/// Tap sur « Réessayer » depuis l'état erreur.
final class TempsEcranReessaye extends TempsEcranEvent {
  /// Crée l'événement de réessai.
  const TempsEcranReessaye();
}

/// Force la recréation du rapport iOS (PlatformView `DeviceActivityReport`).
///
/// Émis (différé) après un octroi d'autorisation : le rapport système est
/// souvent vide à la création immédiate, une recréation le fait apparaître.
final class TempsEcranRechargerRapport extends TempsEcranEvent {
  /// Crée l'événement de rechargement du rapport.
  const TempsEcranRechargerRapport();
}
