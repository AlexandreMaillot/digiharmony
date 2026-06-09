part of 'respiration_bloc.dart';

/// Statut de la seance de respiration.
///
/// [preparation] : decompte 3-2-1 avant le demarrage (sans audio).
enum RespirationStatus { preparation, enCours, enPause, terminee }

/// Etat immuable de la machine de respiration.
class RespirationState extends Equatable {
  /// {@macro respiration_state}
  const RespirationState({
    required this.status,
    required this.phase,
    required this.cycleIndex,
    required this.phaseDurationSeconds,
    this.prepRestant = 0,
    this.statsPersisted = false,
  });

  /// Etat de preparation : decompte (3-2-1) avant le demarrage.
  factory RespirationState.preparation(SeanceRespiration session) =>
      RespirationState(
        status: RespirationStatus.preparation,
        phase: PhaseRespiration.inhale,
        cycleIndex: 0,
        phaseDurationSeconds: session.inhale.inSeconds,
        prepRestant: 3,
      );

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

  /// Secondes restantes du decompte de preparation (3 -> 1).
  final int prepRestant;

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
    int? prepRestant,
    bool? statsPersisted,
  }) {
    return RespirationState(
      status: status ?? this.status,
      phase: phase ?? this.phase,
      cycleIndex: cycleIndex ?? this.cycleIndex,
      phaseDurationSeconds: phaseDurationSeconds ?? this.phaseDurationSeconds,
      prepRestant: prepRestant ?? this.prepRestant,
      statsPersisted: statsPersisted ?? this.statsPersisted,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    phase,
    cycleIndex,
    phaseDurationSeconds,
    prepRestant,
    statsPersisted,
  ];
}
