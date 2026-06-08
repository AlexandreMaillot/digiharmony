part of 'sens_bloc.dart';

/// Statut de l'exercice « Les sens ».
enum SensStatus { enCours, termine }

/// Etat immuable de la progression 5-4-3-2-1.
class SensState extends Equatable {
  /// {@macro sens_state}
  const SensState({
    required this.status,
    required this.exercise,
    required this.stepIndex,
    this.statsPersisted = false,
  });

  /// Etat initial : etape 0, enCours.
  factory SensState.initial(ExerciceAncrage exercise) => SensState(
    status: SensStatus.enCours,
    exercise: exercise,
    stepIndex: 0,
  );

  /// Statut courant.
  final SensStatus status;

  /// Exercice (donnee figee).
  final ExerciceAncrage exercise;

  /// Index 0-based de l'etape courante.
  final int stepIndex;

  /// Garde-fou : agregat ecrit une seule fois.
  final bool statsPersisted;

  /// Etape courante.
  EtapeAncrage get step => exercise.steps[stepIndex];

  /// Vrai si l'etape courante est la derniere.
  bool get isLastStep => stepIndex == exercise.totalSteps - 1;

  /// Etapes deja faites (recap).
  List<EtapeAncrage> get doneSteps => exercise.steps.sublist(0, stepIndex);

  /// Copie modifiee.
  SensState copyWith({
    SensStatus? status,
    int? stepIndex,
    bool? statsPersisted,
  }) {
    return SensState(
      status: status ?? this.status,
      exercise: exercise,
      stepIndex: stepIndex ?? this.stepIndex,
      statsPersisted: statsPersisted ?? this.statsPersisted,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, stepIndex, statsPersisted];
}
