import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/data/local/depot_stats_bien_etre.dart';
import 'package:digiharmony_app/pages/detox/args_detox_lecteur.dart';
import 'package:digiharmony_app/pages/detox/view/detox_lecteur_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Routes internes à la catégorie Détox.
abstract final class RoutesDetox {
  /// Route vers le lecteur audio Détox avec la sélection.
  ///
  /// Le [depot] est transmis explicitement pour traverser la frontière
  /// de route (pattern DEC-FND-07).
  static Route<void> lecteur({
    required IdAmbianceDetox ambianceId,
    required int durationMinutes,
    required DepotStatsBienEtre depot,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => RepositoryProvider<DepotStatsBienEtre>.value(
        value: depot,
        child: DetoxLecteurPage(
          args: ArgsDetoxLecteur(
            ambianceId: ambianceId,
            durationMinutes: durationMinutes,
          ),
        ),
      ),
    );
  }
}
