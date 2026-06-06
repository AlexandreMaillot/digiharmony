import 'dart:io';

import 'package:flutter/services.dart';

/// Flag de bascule : mettre à `true` UNIQUEMENT après :
///   1. Obtention de l'entitlement `com.apple.developer.family-controls`
///      (portail Apple Developer — accès spécial, hors code).
///   2. Regénération des provisioning profiles (Runner + extension, 3 flavors).
///   3. Dans Xcode : activer la capability Screen Time sur le target Runner,
///      ajouter `ScreenTimeScaffold/ScreenTimeAuthorization.swift` au target
///      Runner (Build Phases > Compile Sources), et créer le target
///      `DeviceActivityReportExtension` (voir ScreenTimeScaffold/README.md).
///   4. Mettre ce flag à `true` et relancer `flutter build ios`.
///
/// Tant que ce flag est `false`, le comportement iOS reste `indisponible`
/// (chemin actuel inchangé, DEC-TE-03).
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
/// INERTE tant que [kScreenTimeIosActif] est `false` : le canal n'est jamais
/// appelé sur le chemin actif. Voir les instructions d'activation ci-dessus.
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
      return _parseStatut(resultat);
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
      return _parseStatut(resultat);
    } on PlatformException {
      return StatutAutorisationIos.indisponible;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers internes
  // ---------------------------------------------------------------------------

  StatutAutorisationIos _parseStatut(String? valeur) {
    return switch (valeur) {
      'nonDemande' => StatutAutorisationIos.nonDemande,
      'refuse' => StatutAutorisationIos.refuse,
      'accorde' => StatutAutorisationIos.accorde,
      _ => StatutAutorisationIos.indisponible,
    };
  }
}
