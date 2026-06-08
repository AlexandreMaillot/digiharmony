import 'package:flutter/widgets.dart';

/// Phases d'un cycle de respiration.
enum PhaseRespiration { inhale, hold, exhale }

/// Parametres figes d'une seance de respiration (cadence + nombre de cycles).
///
/// Donnee pure, sans persistance ni collecte.
@immutable
class SeanceRespiration {
  /// {@macro seance_respiration}
  const SeanceRespiration({
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.totalCycles,
  });

  /// Duree de l'inspiration.
  final Duration inhale;

  /// Duree de la retention.
  final Duration hold;

  /// Duree de l'expiration.
  final Duration exhale;

  /// Nombre total de cycles.
  final int totalCycles;

  /// Cadence 4-2-6 x 5 — FIGEE en V1 (aucun selecteur).
  static const SeanceRespiration quatreDeuxSix = SeanceRespiration(
    inhale: Duration(seconds: 4),
    hold: Duration(seconds: 2),
    exhale: Duration(seconds: 6),
    totalCycles: 5,
  );

  /// Duree d'une phase donnee.
  Duration durationOf(PhaseRespiration p) => switch (p) {
    PhaseRespiration.inhale => inhale,
    PhaseRespiration.hold => hold,
    PhaseRespiration.exhale => exhale,
  };

  /// Ordre des phases dans un cycle.
  static const List<PhaseRespiration> ordrePhases = <PhaseRespiration>[
    PhaseRespiration.inhale,
    PhaseRespiration.hold,
    PhaseRespiration.exhale,
  ];
}
