part of 'etirement_bloc.dart';

/// Statut de la routine d'etirement.
///
/// [preparation] : decompte 3-2-1 avant le demarrage (sans audio).
enum EtirementStatus { preparation, enCours, enPause, termine }

/// Statut d'un segment dans la liste.
enum EtirementStatutSegment { fait, actif, aVenir }

/// Vue d'un segment pour la liste (statut + progression).
typedef VueSegmentEtirement = ({
  String labelKey,
  EtirementStatutSegment status,
  double progress,
});

/// Etat immuable de la routine (ticker multi-segments).
class EtirementState extends Equatable {
  /// {@macro etirement_state}
  const EtirementState({
    required this.status,
    required this.segmentIndex,
    required this.segmentElapsed,
    required this.routine,
    this.prepRestant = 0,
    this.statsPersisted = false,
  });

  /// Etat de preparation : decompte (3-2-1) avant le demarrage de la routine.
  factory EtirementState.preparation(RoutineEtirement routine) =>
      EtirementState(
        status: EtirementStatus.preparation,
        segmentIndex: 0,
        segmentElapsed: Duration.zero,
        routine: routine,
        prepRestant: 3,
      );

  /// Etat initial de la routine : segment 0, enCours.
  factory EtirementState.initial(RoutineEtirement routine) => EtirementState(
    status: EtirementStatus.enCours,
    segmentIndex: 0,
    segmentElapsed: Duration.zero,
    routine: routine,
  );

  /// Statut courant.
  final EtirementStatus status;

  /// Index 0-based du segment courant.
  final int segmentIndex;

  /// Temps ecoule dans le segment courant.
  final Duration segmentElapsed;

  /// Routine (donnee figee).
  final RoutineEtirement routine;

  /// Secondes restantes du decompte de preparation (3 -> 1, 0 = routine).
  final int prepRestant;

  /// Garde-fou : agregat ecrit une seule fois.
  final bool statsPersisted;

  /// Segment courant.
  SegmentEtirement get segment => routine.segments[segmentIndex];

  /// Progression 0->1 du segment courant.
  double get segmentProgress => segment.duration.inMilliseconds == 0
      ? 1
      : (segmentElapsed.inMilliseconds / segment.duration.inMilliseconds).clamp(
          0.0,
          1.0,
        );

  /// Temps GLOBAL ecoule.
  Duration get globalElapsed => status == EtirementStatus.termine
      ? routine.totalDuration
      : routine.startOf(segmentIndex) + segmentElapsed;

  /// Temps GLOBAL restant.
  Duration get globalRemaining => routine.totalDuration - globalElapsed;

  /// Borne globale de debut du segment courant.
  Duration get segmentStart => routine.startOf(segmentIndex);

  /// Borne globale de fin du segment courant.
  Duration get segmentEnd => routine.endOf(segmentIndex);

  /// Vue par segment pour la liste.
  List<VueSegmentEtirement> get vuesSegments => <VueSegmentEtirement>[
    for (var i = 0; i < routine.totalSegments; i++)
      (
        labelKey: routine.segments[i].labelKey,
        status: _statutPour(i),
        progress: _progressionPour(i),
      ),
  ];

  EtirementStatutSegment _statutPour(int i) {
    if (i < segmentIndex) return EtirementStatutSegment.fait;
    if (i == segmentIndex) {
      return status == EtirementStatus.termine
          ? EtirementStatutSegment.fait
          : EtirementStatutSegment.actif;
    }
    return EtirementStatutSegment.aVenir;
  }

  double _progressionPour(int i) {
    if (i < segmentIndex) return 1;
    if (i == segmentIndex) {
      return status == EtirementStatus.termine ? 1 : segmentProgress;
    }
    return 0;
  }

  /// Copie modifiee.
  EtirementState copyWith({
    EtirementStatus? status,
    int? segmentIndex,
    Duration? segmentElapsed,
    int? prepRestant,
    bool? statsPersisted,
  }) {
    return EtirementState(
      status: status ?? this.status,
      segmentIndex: segmentIndex ?? this.segmentIndex,
      segmentElapsed: segmentElapsed ?? this.segmentElapsed,
      routine: routine,
      prepRestant: prepRestant ?? this.prepRestant,
      statsPersisted: statsPersisted ?? this.statsPersisted,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    segmentIndex,
    segmentElapsed,
    prepRestant,
    statsPersisted,
  ];
}
