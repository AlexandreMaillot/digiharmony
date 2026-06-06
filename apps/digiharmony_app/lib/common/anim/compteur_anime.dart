/// Widget utilitaire : compteur animé count-up.
///
/// - [CompteurAnimeInt] : entier animé (ex. nombre d'entrées).
/// - [CompteurAnimeDuree] : durée animée (ex. temps d'écran).
/// - No-op en reduced-motion : valeur finale affichée directement.
library;

import 'package:digiharmony_app/common/anim/anim_constants.dart';
import 'package:flutter/material.dart';

/// Compteur animé pour une valeur entière.
///
/// Anime de 0 à [valeur] en [dureeCompteur].
/// En reduced-motion → affiche [valeur] directement.
class CompteurAnimeInt extends StatelessWidget {
  /// Crée un compteur entier animé.
  const CompteurAnimeInt({
    required this.valeur,
    required this.builder,
    super.key,
  });

  /// Valeur cible (affichée à la fin de l'animation).
  final int valeur;

  /// Constructeur de widget à partir de la valeur courante.
  final Widget Function(BuildContext context, int valeurCourante) builder;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (disableAnimations) return builder(context, valeur);

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: valeur),
      duration: dureeCompteur,
      curve: curveEntree,
      builder: (context, valeurCourante, _) =>
          builder(context, valeurCourante),
    );
  }
}

/// Compteur animé pour une durée.
///
/// Anime de [Duration.zero] à [duree] en [dureeCompteur].
/// En reduced-motion → affiche [duree] directement.
class CompteurAnimeDuree extends StatelessWidget {
  /// Crée un compteur de durée animé.
  const CompteurAnimeDuree({
    required this.duree,
    required this.builder,
    super.key,
  });

  /// Durée cible (affichée à la fin de l'animation).
  final Duration duree;

  /// Constructeur de widget à partir de la durée courante.
  final Widget Function(BuildContext context, Duration dureeCourante) builder;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (disableAnimations) return builder(context, duree);

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: duree.inSeconds),
      duration: dureeCompteur,
      curve: curveEntree,
      builder: (context, secondesCourants, _) =>
          builder(context, Duration(seconds: secondesCourants)),
    );
  }
}
