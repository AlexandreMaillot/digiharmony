import 'package:flutter/material.dart';

/// Modèle d'une étape du tutoriel (numéro implicite par position).
///
/// Données purement statiques (icône + clés i18n résolues à l'affichage) —
/// aucune persistance (DEC-TN-04).
@immutable
class EtapeTutoModele {
  /// Crée une étape.
  const EtapeTutoModele({
    required this.icone,
    required this.titre,
    required this.corps,
  });

  /// Icône Material (équivalent de l'icône Lucide de la maquette).
  final IconData icone;

  /// Titre de l'étape (texte déjà localisé).
  final String titre;

  /// Description de l'étape (texte déjà localisé).
  final String corps;
}
