import 'package:flutter/material.dart';

/// Interface du service de rappel quotidien d'humeur (100 % locale, DEC-R-01).
///
/// Abstrait le plugin `flutter_local_notifications` pour permettre le mock en
/// test (aucune dépendance OS réelle dans les tests — plan section M/D).
/// L'implémentation réelle enveloppe le plugin.
abstract interface class ServiceRappel {
  /// Initialise le moteur de notifications (timezone + plugin + handler tap).
  ///
  /// Appelé depuis `bootstrap.dart` via le hook `notifInit` injectable.
  /// No-op en test (hook remplacé par `() async {}`).
  Future<void> initialiser();

  /// Demande la permission d'afficher des notifications.
  ///
  /// Retourne `true` si la permission est accordée, `false` sinon.
  /// Ne doit être appelé qu'après la page priming (DEC-R-05).
  Future<bool> demanderPermission();

  /// Vérifie si la permission est actuellement accordée côté OS.
  ///
  /// Utilisé pour la réconciliation état HydratedBloc ↔ OS (DEC-R-06).
  Future<bool> permissionAccordee();

  /// Planifie la prochaine notification de rappel (one-shot, DEC-R-04).
  ///
  /// Calcule la cible :
  /// - Si [dejaNoteAujourdhui] == `true` → demain à [heure].
  /// - Si [dejaNoteAujourdhui] == `false` et l'heure n'est pas passée →
  ///   aujourd'hui à [heure].
  /// - Si [dejaNoteAujourdhui] == `false` et l'heure est passée →
  ///   demain à [heure].
  ///
  /// [titre] et [corps] sont les chaînes localisées à afficher dans la notif.
  /// Ils doivent être NON vides — le bloc fournit toujours les clés ARB
  /// résolues depuis la locale courante (BLOCKER-1 / DEC-R-04).
  ///
  /// Annule toute notification en attente avant de planifier.
  Future<void> planifierProchainRappel({
    required TimeOfDay heure,
    required bool dejaNoteAujourdhui,
    required String titre,
    required String corps,
  });

  /// Annule toutes les notifications en attente.
  Future<void> annulerTout();

  /// DEBUG : affiche immédiatement une notification de test.
  ///
  /// Bypass total de la planification — sert uniquement à vérifier que le
  /// tuyau OS fonctionne (permission, canal, affichage, tap→saisie),
  /// indépendamment de la logique « heure / déjà noté ». Non destiné à la prod.
  Future<void> afficherNotificationTest({
    required String titre,
    required String corps,
  });
}
