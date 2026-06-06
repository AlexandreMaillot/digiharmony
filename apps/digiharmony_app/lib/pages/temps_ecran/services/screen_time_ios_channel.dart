import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Flag de bascule du chemin iOS Screen Time.
///
/// **Actuellement `true`** : la plomberie native est câblée (canal
/// `digiharmony/screen_time` + extension `DeviceActivityReportExtension`,
/// capability « Family Controls (Development) »), donc la View peut emprunter
/// le chemin iOS réel. Au runtime, si l'entitlement n'est pas effectivement
/// provisionné (ex. flavor sans profil régénéré), le canal natif renvoie
/// `indisponible` et l'UI dégrade proprement (pas de crash —
/// `AppDelegate.swift`).
///
/// Repasser à `false` désactive entièrement le chemin iOS (statut forcé
/// `indisponible`, canal jamais appelé). Prérequis pour la **distribution**
/// App Store (≠ Development) : entitlement
/// `com.apple.developer.family-controls` approuvé par Apple + provisioning
/// régénéré (Runner + extension, 3 flavors). Matériel de référence :
/// `ScreenTimeScaffold/README.md`. Voir DEC-006/DEC-TE-03.
const bool kScreenTimeIosActif = true;

/// Statut d'autorisation FamilyControls retourné par le canal natif iOS.
///
/// Mapping avec `AuthorizationStatus` Swift :
///   - `nonDemande`   → `.notDetermined`
///   - `refuse`       → `.denied`
///   - `accorde`      → `.approved`
///   - `indisponible` → API indispo / entitlement absent / iOS < cible
enum StatutAutorisationIos {
  /// Autorisation pas encore demandée (état initial).
  nonDemande,

  /// L'utilisateur a refusé l'accès, ou `requestAuthorization` a échoué.
  refuse,

  /// L'accès FamilyControls est accordé : le rapport peut être affiché.
  accorde,

  /// Entitlement absent, API indisponible, simulateur, ou iOS < cible.
  indisponible,
}

/// Wrapper autour du [MethodChannel] `digiharmony/screen_time` (côté Dart).
///
/// Le canal n'est emprunté que lorsque [kScreenTimeIosActif] est `true`
/// (cas actuel) ; sinon le chemin iOS est totalement court-circuité en amont.
///
/// Méthodes exposées :
///   - [statutAutorisation] : lecture silencieuse du statut FamilyControls
///     (ne déclenche pas de pop-up système).
///   - [demanderAutorisation] : déclenche la demande native (à n'appeler
///     qu'après CTA explicite de l'utilisateur — DEC-TE-15).
class ScreenTimeIosChannel {
  /// Crée le canal. [canal] injectable pour les tests.
  ScreenTimeIosChannel({MethodChannel? canal})
    : _canal =
          canal ??
          const MethodChannel('digiharmony/screen_time');

  final MethodChannel _canal;

  /// Lit silencieusement le statut d'autorisation FamilyControls.
  ///
  /// Ne déclenche pas de pop-up système. Retourne
  /// [StatutAutorisationIos.indisponible] en cas d'erreur native
  /// (entitlement absent, etc.).
  Future<StatutAutorisationIos> statutAutorisation() async {
    if (!Platform.isIOS) return StatutAutorisationIos.indisponible;
    try {
      final resultat =
          await _canal.invokeMethod<String>('statutAutorisation');
      return parseStatut(resultat);
    } on PlatformException {
      return StatutAutorisationIos.indisponible;
    }
  }

  /// Déclenche
  /// `AuthorizationCenter.shared.requestAuthorization(for: .individual)`.
  ///
  /// À n'appeler qu'après que l'utilisateur a explicitement tapé le CTA
  /// « Autoriser » (principe d'octroi validé, DEC-TE-15).
  ///
  /// Retourne le statut résultant. Retourne
  /// [StatutAutorisationIos.indisponible] en cas d'erreur native
  /// (entitlement absent, refus système, etc.).
  Future<StatutAutorisationIos> demanderAutorisation() async {
    if (!Platform.isIOS) return StatutAutorisationIos.indisponible;
    try {
      final resultat =
          await _canal.invokeMethod<String>('demanderAutorisation');
      return parseStatut(resultat);
    } on PlatformException {
      return StatutAutorisationIos.indisponible;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers internes
  // ---------------------------------------------------------------------------

  /// Convertit la chaîne brute du canal natif en [StatutAutorisationIos].
  ///
  /// Toute valeur inconnue ou `null` → [StatutAutorisationIos.indisponible]
  /// (jamais d'exception). Exposé pour les tests : le mapping est le contrat
  /// avec le code Swift, le garde-fou `Platform.isIOS` empêchant de l'exercer
  /// via les méthodes publiques sur l'hôte de test.
  @visibleForTesting
  static StatutAutorisationIos parseStatut(String? valeur) {
    return switch (valeur) {
      'nonDemande' => StatutAutorisationIos.nonDemande,
      'refuse' => StatutAutorisationIos.refuse,
      'accorde' => StatutAutorisationIos.accorde,
      _ => StatutAutorisationIos.indisponible,
    };
  }
}
