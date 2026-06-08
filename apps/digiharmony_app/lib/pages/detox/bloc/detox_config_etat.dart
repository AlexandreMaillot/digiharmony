part of 'detox_config_bloc.dart';

/// Etat de selection Detox : ambiance + duree.
class DetoxConfigEtat extends Equatable {
  /// {@macro detox_config_etat}
  const DetoxConfigEtat({
    required this.ambianceId,
    required this.durationMinutes,
  });

  /// Defauts produit (premiere ouverture) : Mer + 5 min.
  factory DetoxConfigEtat.initial() => const DetoxConfigEtat(
    ambianceId: IdAmbianceDetox.sea,
    durationMinutes: 5,
  );

  /// Ambiance selectionnee.
  final IdAmbianceDetox ambianceId;

  /// Duree selectionnee (minutes).
  final int durationMinutes;

  /// Ambiance derivee (icone/couleur/asset).
  AmbianceDetox get ambiance => AmbianceDetox.parId(ambianceId);

  /// Copie modifiee.
  DetoxConfigEtat copyWith({
    IdAmbianceDetox? ambianceId,
    int? durationMinutes,
  }) {
    return DetoxConfigEtat(
      ambianceId: ambianceId ?? this.ambianceId,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  @override
  List<Object?> get props => <Object?>[ambianceId, durationMinutes];
}
