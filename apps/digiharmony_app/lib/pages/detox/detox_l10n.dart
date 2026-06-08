import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Resolution ambiance -> label / description / icone (partage config + lecteur).
extension AmbianceDetoxL10n on IdAmbianceDetox {
  /// Libelle traduit de l'ambiance.
  String ambianceLabel(AppLocalizations l) => switch (this) {
    IdAmbianceDetox.water => l.detoxAmbianceWaterLabel,
    IdAmbianceDetox.sea => l.detoxAmbianceSeaLabel,
    IdAmbianceDetox.whiteNoise => l.detoxAmbianceWhiteNoiseLabel,
    IdAmbianceDetox.forest => l.detoxAmbianceForestLabel,
  };

  /// Description traduite de l'ambiance.
  String ambianceDescription(AppLocalizations l) => switch (this) {
    IdAmbianceDetox.water => l.detoxAmbianceWaterDesc,
    IdAmbianceDetox.sea => l.detoxAmbianceSeaDesc,
    IdAmbianceDetox.whiteNoise => l.detoxAmbianceWhiteNoiseDesc,
    IdAmbianceDetox.forest => l.detoxAmbianceForestDesc,
  };

  /// Icone Material de l'ambiance.
  IconData get ambianceIcon => switch (this) {
    IdAmbianceDetox.water => Icons.water,
    IdAmbianceDetox.sea => Icons.waves,
    IdAmbianceDetox.whiteNoise => Icons.graphic_eq,
    IdAmbianceDetox.forest => Icons.forest,
  };
}
