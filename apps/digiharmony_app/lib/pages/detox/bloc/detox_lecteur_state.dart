part of 'detox_lecteur_bloc.dart';

/// Statut du lecteur Detox.
enum DetoxLecteurStatus { enLecture, termine }

/// Etat immuable du lecteur (timer / progression).
class DetoxLecteurState extends Equatable {
  /// {@macro detox_lecteur_state}
  const DetoxLecteurState({
    required this.status,
    required this.total,
    required this.elapsed,
    this.statsPersisted = false,
  });

  /// Statut courant.
  final DetoxLecteurStatus status;

  /// Duree totale.
  final Duration total;

  /// Temps ecoule.
  final Duration elapsed;

  /// Garde-fou : agregat ecrit une seule fois.
  final bool statsPersisted;

  /// Temps restant.
  Duration get remaining => total - elapsed;

  /// Progression 0->1 (barre + arc).
  double get progress => total.inMilliseconds == 0
      ? 0
      : (elapsed.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);

  /// Degre d'epanouissement de la fleur 0->1 (derive de la progression).
  double get bloomProgress => progress;

  /// Copie modifiee.
  DetoxLecteurState copyWith({
    DetoxLecteurStatus? status,
    Duration? total,
    Duration? elapsed,
    bool? statsPersisted,
  }) {
    return DetoxLecteurState(
      status: status ?? this.status,
      total: total ?? this.total,
      elapsed: elapsed ?? this.elapsed,
      statsPersisted: statsPersisted ?? this.statsPersisted,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, total, elapsed, statsPersisted];
}
