import 'package:flutter/material.dart';

/// Identifiant stable d'une categorie de bulle (sert au routing cote app).
enum IdCategorieBulle { respiration, senses, stretch, detox }

/// Donnee statique, immuable, d'une bulle apaisante.
///
/// Aucune persistance, aucune collecte : liste const en memoire. Le texte
/// (label/hint/duree) est resolu via l'ARB cote app, pas stocke ici.
@immutable
class CategorieBulle {
  /// {@macro categorie_bulle}
  const CategorieBulle({
    required this.id,
    required this.icon,
    required this.color,
  });

  /// Identifiant stable de la categorie.
  final IdCategorieBulle id;

  /// Icone Material associee.
  final IconData icon;

  /// Couleur d'accent de la bulle.
  final Color color;

  /// Les 4 bulles, ordre = ordre d'affichage de la grille 2x2.
  static const List<CategorieBulle> all = <CategorieBulle>[
    CategorieBulle(
      id: IdCategorieBulle.respiration,
      icon: Icons.air,
      color: Color(0xFF3FB8E6),
    ),
    CategorieBulle(
      id: IdCategorieBulle.senses,
      icon: Icons.visibility_outlined,
      color: Color(0xFF9B7BE8),
    ),
    CategorieBulle(
      id: IdCategorieBulle.stretch,
      icon: Icons.self_improvement,
      color: Color(0xFF5FC98A),
    ),
    CategorieBulle(
      id: IdCategorieBulle.detox,
      icon: Icons.eco_outlined,
      color: Color(0xFF8FE08F),
    ),
  ];
}
