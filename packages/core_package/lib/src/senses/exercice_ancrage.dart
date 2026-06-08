import 'package:flutter/widgets.dart';

/// Les 5 sens de l'ancrage 5-4-3-2-1.
enum SensAncrage { see, touch, hear, smell, taste }

/// Une etape de l'ancrage sensoriel : un sens + un compte.
///
/// Le texte (label/instruction) n'est PAS stocke ici : il est resolu via
/// l'ARB cote app, pour rester traduisible.
@immutable
class EtapeAncrage {
  /// {@macro etape_ancrage}
  const EtapeAncrage({required this.sense, required this.count});

  /// Sens cible de l'etape.
  final SensAncrage sense;

  /// Nombre d'elements a identifier (5 / 4 / 3 / 2 / 1).
  final int count;
}

/// Exercice d'ancrage sensoriel 5-4-3-2-1 (grounding), donnee pure figee.
@immutable
class ExerciceAncrage {
  /// {@macro exercice_ancrage}
  const ExerciceAncrage({required this.steps});

  /// Etapes ordonnees de l'exercice.
  final List<EtapeAncrage> steps;

  /// Nombre total d'etapes.
  int get totalSteps => steps.length;

  /// Technique 5-4-3-2-1 — FIGEE en V1 (ordre et comptes immuables).
  static const ExerciceAncrage cinqQuatreTroisDeuxUn = ExerciceAncrage(
    steps: <EtapeAncrage>[
      EtapeAncrage(sense: SensAncrage.see, count: 5),
      EtapeAncrage(sense: SensAncrage.touch, count: 4),
      EtapeAncrage(sense: SensAncrage.hear, count: 3),
      EtapeAncrage(sense: SensAncrage.smell, count: 2),
      EtapeAncrage(sense: SensAncrage.taste, count: 1),
    ],
  );
}
