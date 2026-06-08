import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/detox/args_detox_lecteur.dart';
import 'package:digiharmony_app/detox/view/detox_lecteur_page.dart';
import 'package:flutter/material.dart';

/// Routes internes a la categorie Detox.
abstract final class RoutesDetox {
  /// Route vers le lecteur audio Detox avec la selection.
  static Route<void> lecteur({
    required IdAmbianceDetox ambianceId,
    required int durationMinutes,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => DetoxLecteurPage(
        args: ArgsDetoxLecteur(
          ambianceId: ambianceId,
          durationMinutes: durationMinutes,
        ),
      ),
    );
  }
}
