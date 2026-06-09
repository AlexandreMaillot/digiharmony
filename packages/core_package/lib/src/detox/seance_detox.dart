import 'package:core_package/src/detox/catalogue_detox.dart';
import 'package:flutter/widgets.dart';

/// Parametres d'une seance de lecture Detox : ambiance + duree totale.
///
/// Donnee pure (aucune logique de lecture ici).
@immutable
class SeanceDetox {
  /// {@macro seance_detox}
  const SeanceDetox({required this.ambianceId, required this.total});

  /// Ambiance choisie a la configuration.
  final IdAmbianceDetox ambianceId;

  /// Duree totale de la pause.
  final Duration total;

  /// Chemin de l'asset audio local de l'ambiance (zero reseau).
  String get audioAsset => AmbianceDetox.parId(ambianceId).audioAsset;
}
