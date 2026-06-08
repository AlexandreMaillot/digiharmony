import 'package:flutter/material.dart';

/// Identifiant stable d'une ambiance Detox.
///
/// Sert au routing, a la resolution i18n et au chemin de l'asset audio.
enum IdAmbianceDetox { water, sea, whiteNoise, forest }

/// Ambiance sonore Detox — donnee statique immuable.
///
/// Aucune persistance, aucune collecte. Le texte (nom/description) est resolu
/// via l'ARB cote app.
@immutable
class AmbianceDetox {
  /// {@macro ambiance_detox}
  const AmbianceDetox({
    required this.id,
    required this.icon,
    required this.color,
    required this.audioAsset,
  });

  /// Identifiant stable de l'ambiance.
  final IdAmbianceDetox id;

  /// Icone Material associee.
  final IconData icon;

  /// Couleur d'accent.
  final Color color;

  /// Asset audio local (joue par le lecteur, pas a la config).
  final String audioAsset;

  /// Les 4 ambiances, ordre = ordre de la grille 2x2.
  static const List<AmbianceDetox> all = <AmbianceDetox>[
    AmbianceDetox(
      id: IdAmbianceDetox.water,
      icon: Icons.water_drop_outlined,
      color: Color(0xFF3FB8E6),
      audioAsset: 'assets/audio/detox/eau.mp3',
    ),
    AmbianceDetox(
      id: IdAmbianceDetox.sea,
      icon: Icons.waves,
      color: Color(0xFF2FAE5F),
      audioAsset: 'assets/audio/detox/mer.mp3',
    ),
    AmbianceDetox(
      id: IdAmbianceDetox.whiteNoise,
      icon: Icons.graphic_eq,
      color: Color(0xFFA7B6CE),
      audioAsset: 'assets/audio/detox/bruit_blanc.mp3',
    ),
    AmbianceDetox(
      id: IdAmbianceDetox.forest,
      icon: Icons.park_outlined,
      color: Color(0xFFA8D24E),
      audioAsset: 'assets/audio/detox/foret.mp3',
    ),
  ];

  /// Ambiance par defaut (si aucune selection memorisee).
  static const IdAmbianceDetox idParDefaut = IdAmbianceDetox.sea;

  /// Resout une ambiance par son identifiant.
  static AmbianceDetox parId(IdAmbianceDetox id) =>
      all.firstWhere((a) => a.id == id);
}

/// Duree de pause Detox (minutes). Liste statique 5 / 10 / 15.
@immutable
class DureeDetox {
  /// {@macro duree_detox}
  const DureeDetox({required this.minutes, this.isDefault = false});

  /// Duree en minutes.
  final int minutes;

  /// Pilote le badge DEFAUT (15 min).
  final bool isDefault;

  /// Les 3 durees proposees.
  static const List<DureeDetox> all = <DureeDetox>[
    DureeDetox(minutes: 5),
    DureeDetox(minutes: 10),
    DureeDetox(minutes: 15, isDefault: true),
  ];

  /// Duree par defaut (si aucune selection memorisee) = 15 min.
  static const int minutesParDefaut = 15;

  /// Minutes autorisees.
  static const List<int> minutesAutorises = <int>[5, 10, 15];
}
