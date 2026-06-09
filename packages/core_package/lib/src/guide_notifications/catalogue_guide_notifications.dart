import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Plateforme dont on affiche les etapes de reglages.
enum PlateformeGuide { android, ios }

/// Une etape du guide « Couper mes notifications ». Donnee pure, immuable,
/// SANS I/O.
///
/// Les libelles sont des CLES i18n (resolues cote app), jamais du texte en
/// dur. L'icone est un `IconData` Material (const), pas un asset, pas de
/// reseau — reste donnee pure (pas de widget).
class EtapeGuideNotifications extends Equatable {
  /// {@macro etape_guide_notifications}
  const EtapeGuideNotifications({
    required this.index,
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
  });

  /// Numero de pastille affiche (1..5).
  final int index;

  /// Cle ARB du titre.
  final String titleKey;

  /// Cle ARB de la description.
  final String bodyKey;

  /// Icone Material (const).
  final IconData icon;

  @override
  List<Object?> get props => <Object?>[index, titleKey, bodyKey, icon];
}

/// Catalogue fige V1 : 2 jeux d'etapes (Android / iOS).
///
/// Style identique aux modeles existants (`static const` fige, cles i18n).
abstract final class CatalogueGuideNotifications {
  /// Jeu d'etapes Android (jeu par defaut).
  static const List<EtapeGuideNotifications> androidSteps =
      <EtapeGuideNotifications>[
    EtapeGuideNotifications(
      index: 1,
      titleKey: 'notifGuideStep1Title',
      bodyKey: 'notifGuideStep1Body',
      icon: Icons.settings,
    ),
    EtapeGuideNotifications(
      index: 2,
      titleKey: 'notifGuideStep2Title',
      bodyKey: 'notifGuideStep2Body',
      icon: Icons.notifications,
    ),
    EtapeGuideNotifications(
      index: 3,
      titleKey: 'notifGuideStep3Title',
      bodyKey: 'notifGuideStep3Body',
      icon: Icons.phone_android,
    ),
    EtapeGuideNotifications(
      index: 4,
      titleKey: 'notifGuideStep4Title',
      bodyKey: 'notifGuideStep4Body',
      icon: Icons.notifications_off,
    ),
    EtapeGuideNotifications(
      index: 5,
      titleKey: 'notifGuideStep5Title',
      bodyKey: 'notifGuideStep5Body',
      icon: Icons.check_circle,
    ),
  ];

  /// Jeu d'etapes iOS (suffixe `Ios` cote cles i18n).
  static const List<EtapeGuideNotifications> iosSteps =
      <EtapeGuideNotifications>[
    EtapeGuideNotifications(
      index: 1,
      titleKey: 'notifGuideStep1TitleIos',
      bodyKey: 'notifGuideStep1BodyIos',
      icon: Icons.settings,
    ),
    EtapeGuideNotifications(
      index: 2,
      titleKey: 'notifGuideStep2TitleIos',
      bodyKey: 'notifGuideStep2BodyIos',
      icon: Icons.notifications,
    ),
    EtapeGuideNotifications(
      index: 3,
      titleKey: 'notifGuideStep3TitleIos',
      bodyKey: 'notifGuideStep3BodyIos',
      icon: Icons.phone_iphone,
    ),
    EtapeGuideNotifications(
      index: 4,
      titleKey: 'notifGuideStep4TitleIos',
      bodyKey: 'notifGuideStep4BodyIos',
      icon: Icons.notifications_off,
    ),
    EtapeGuideNotifications(
      index: 5,
      titleKey: 'notifGuideStep5TitleIos',
      bodyKey: 'notifGuideStep5BodyIos',
      icon: Icons.check_circle,
    ),
  ];

  /// Etapes pour la plateforme donnee.
  static List<EtapeGuideNotifications> etapesPour(PlateformeGuide p) =>
      p == PlateformeGuide.ios ? iosSteps : androidSteps;
}
