import 'package:equatable/equatable.dart';

/// Identifiants stables des segments d'etirement.
enum IdSegmentEtirement { anchor, neckShoulders, hands, restEyes }

/// Un segment minute de la routine d'etirement.
///
/// Les libelles/instructions sont des CLES i18n (resolues cote app),
/// jamais du texte en dur.
class SegmentEtirement extends Equatable {
  /// {@macro segment_etirement}
  const SegmentEtirement({
    required this.id,
    required this.labelKey,
    required this.instructionKey,
    required this.duration,
  });

  /// Identifiant stable du segment.
  final IdSegmentEtirement id;

  /// Cle ARB du titre.
  final String labelKey;

  /// Cle ARB de l'instruction.
  final String instructionKey;

  /// Duree fixe du segment.
  final Duration duration;

  @override
  List<Object?> get props =>
      <Object?>[id, labelKey, instructionKey, duration];
}

/// Routine d'etirement multi-segments minutee, donnee pure figee.
class RoutineEtirement extends Equatable {
  /// {@macro routine_etirement}
  const RoutineEtirement({required this.segments});

  /// Segments ordonnes de la routine.
  final List<SegmentEtirement> segments;

  /// Nombre total de segments.
  int get totalSegments => segments.length;

  /// Total de la routine = SOMME des durees des segments.
  Duration get totalDuration =>
      segments.fold(Duration.zero, (acc, s) => acc + s.duration);

  /// Debut global (cumul) du segment d'index [i].
  Duration startOf(int i) =>
      segments.take(i).fold(Duration.zero, (acc, s) => acc + s.duration);

  /// Fin globale (cumul) du segment d'index [i].
  Duration endOf(int i) => startOf(i) + segments[i].duration;

  /// Routine FIGEE en V1 — 4 segments, durees indicatives (total 60 s).
  static const RoutineEtirement routineParDefaut = RoutineEtirement(
    segments: <SegmentEtirement>[
      SegmentEtirement(
        id: IdSegmentEtirement.anchor,
        labelKey: 'stretchSegmentAnchorLabel',
        instructionKey: 'stretchSegmentAnchorInstruction',
        duration: Duration(seconds: 10),
      ),
      SegmentEtirement(
        id: IdSegmentEtirement.neckShoulders,
        labelKey: 'stretchSegmentNeckShouldersLabel',
        instructionKey: 'stretchSegmentNeckShouldersInstruction',
        duration: Duration(seconds: 20),
      ),
      SegmentEtirement(
        id: IdSegmentEtirement.hands,
        labelKey: 'stretchSegmentHandsLabel',
        instructionKey: 'stretchSegmentHandsInstruction',
        duration: Duration(seconds: 15),
      ),
      SegmentEtirement(
        id: IdSegmentEtirement.restEyes,
        labelKey: 'stretchSegmentRestEyesLabel',
        instructionKey: 'stretchSegmentRestEyesInstruction',
        duration: Duration(seconds: 15),
      ),
    ],
  );

  @override
  List<Object?> get props => <Object?>[segments];
}
