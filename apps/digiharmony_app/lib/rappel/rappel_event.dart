part of 'rappel_bloc.dart';

/// Événements du [RappelBloc].
sealed class RappelEvent {
  const RappelEvent();
}

/// Demande d'activation (après permission accordée depuis la page priming).
///
/// Déclenche `actif=true` et la planification du prochain rappel.
final class RappelActivationDemandee extends RappelEvent {
  /// Crée l'événement.
  const RappelActivationDemandee();
}

/// Désactivation explicite (toggle off dans Paramètres).
///
/// Déclenche `actif=false` + annulation de toute notification en attente.
final class RappelDesactive extends RappelEvent {
  /// Crée l'événement.
  const RappelDesactive();
}

/// Changement de l'heure du rappel.
///
/// Si le rappel est actif, déclenche une replanification.
final class RappelHeureChangee extends RappelEvent {
  /// Crée l'événement avec la nouvelle [heure].
  const RappelHeureChangee(this.heure);

  /// Nouvelle heure choisie par l'utilisateur.
  final TimeOfDay heure;
}

/// Refus ou révocation de la permission OS.
///
/// Déclenche `actif=false` + `permissionRefusee=true`. Pas de crash.
final class RappelPermissionRefusee extends RappelEvent {
  /// Crée l'événement.
  const RappelPermissionRefusee();
}

/// Demande de replanification (démarrage/résumé app, après saisie, DEC-R-04).
///
/// Lit `humeurDuJourEstNotee` via Drift puis replanifie si actif.
/// Réconcilie également l'état de permission OS (DEC-R-06).
final class RappelReplanificationDemandee extends RappelEvent {
  /// Crée l'événement.
  const RappelReplanificationDemandee();
}

/// Pose le flag `invitationDejaProposee=true` (one-shot, DEC-R-03).
///
/// Idempotent : un deuxième appel ne change plus rien.
final class RappelInvitationProposee extends RappelEvent {
  /// Crée l'événement.
  const RappelInvitationProposee();
}

/// DEBUG : déclenche une notification de test immédiate.
///
/// Outil de diagnostic uniquement (vérifie le tuyau OS), sans incidence sur
/// l'état ni la planification.
final class RappelTestDemande extends RappelEvent {
  /// Crée l'événement.
  const RappelTestDemande();
}
