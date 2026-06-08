part of 'respiration_bloc.dart';

/// Statut de la seance de respiration.
enum RespirationStatus { enCours, enPause, terminee }

/// Etat immuable de la machine de respiration.
class RespirationState extends Equatable {
  /// {@macro respiration_state}
  const RespirationState({
    required this.status,
    required this.phase,
    required this.cycleIndex,
    required this.phaseDurationSeconds,
    this.statsPersisted = false,
  });

  /// Etat initial : cycle 0, phase inhale, enCours.
  factory RespirationState.initial(SeanceRespiration session) =>
      RespirationState(
        status: RespirationStatus.enCours,
        phase: PhaseRespiration.inhale,
        cycleIndex: 0,
        phaseDurationSeconds: session.inhale.inSeconds,
      );

  /// Statut courant.
  final RespirationStatus status;

  /// Phase courante.
  final PhaseRespiration phase;

  /// Index 0-based du cycle.
  final int cycleIndex;

  /// Duree (s) de la phase courante.
  final int phaseDurationSeconds;

  /// Garde-fou : agregat ecrit une seule fois.
  final bool statsPersisted;

  /// Numero 1-based du cycle pour l'affichage.
  int get cycleNumber => cycleIndex + 1;

  /// Copie modifiee.
  RespirationState copyWith({
    RespirationStatus? status,
    PhaseRespiration? phase,
    int? cycleIndex,
    int? phaseDurationSeconds,
    bool? statsPersisted,
  }) {
    return RespirationState(
      status: status ?? this.status,
      phase: phase ?? this.phase,
      cycleIndex: cycleIndex ?? this.cycleIndex,
      phaseDurationSeconds: phaseDurationSeconds ?? this.phaseDurationSeconds,
      statsPersisted: statsPersisted ?? this.statsPersisted,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    phase,
    cycleIndex,
    phaseDurationSeconds,
    statsPersisted,
  ];
}
