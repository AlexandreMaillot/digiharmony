import 'package:core_package/core_package.dart';
import 'package:flutter/foundation.dart';

/// Contrat de navigation entrant du lecteur Detox.
@immutable
class ArgsDetoxLecteur {
  /// {@macro args_detox_lecteur}
  const ArgsDetoxLecteur({
    required this.ambianceId,
    required this.durationMinutes,
  });

  /// Ambiance choisie a la configuration.
  final IdAmbianceDetox ambianceId;

  /// Duree choisie (minutes).
  final int durationMinutes;
}
