import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Halo dégradé radial « respirant », partagé entre Demarrage et Accueil.
///
/// Paramétrable pour couvrir les deux usages :
/// - Demarrage (splash) : taille 240, dégradé cyan monochrome, flag `animer`
///   injecté par le parent (qui lit `MediaQuery.disableAnimations`).
/// - Accueil : taille 340, dégradé cyan→signature→fond, flag lu depuis
///   `MediaQuery.disableAnimations` en interne.
///
/// a11y : en mode reduced motion, le halo est rendu **statique** (DEC-S-005).
class HaloRespirant extends StatelessWidget {
  /// Crée un halo respirant.
  ///
  /// [taille] : diamètre du cercle (défaut 340 pour l'Accueil).
  /// [couleurs] : liste de couleurs du dégradé radial (défaut palette Accueil).
  /// [opaciteStatique] : opacité appliquée en mode reduced motion (défaut 1.0).
  /// [animer] : si non null, remplace la lecture de
  ///   `MediaQuery.disableAnimations`. Passer `false` force le statique.
  const HaloRespirant({
    this.taille = 340,
    this.couleurs,
    this.opaciteStatique = 1.0,
    this.animer,
    super.key,
  });

  /// Diamètre du cercle de halo.
  final double taille;

  /// Couleurs du dégradé radial. Si `null`, utilise la palette Accueil.
  final List<Color>? couleurs;

  /// Opacité appliquée au widget statique (reduced motion).
  final double opaciteStatique;

  /// Surcharge le flag `MediaQuery.disableAnimations`.
  ///
  /// - `null` (défaut) → lit `MediaQuery.disableAnimations`.
  /// - `false` → force la boucle (usage : test explicite).
  /// - `true` → force le statique (usage : Demarrage avec reduced motion).
  final bool? animer;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        animer != null ? !animer! : MediaQuery.of(context).disableAnimations;

    final couleursEffectives = couleurs ??
        [
          AppColors.primary.withValues(alpha: 0.18),
          AppColors.signatureGradient[1].withValues(alpha: 0.08),
          AppColors.background.withValues(alpha: 0),
        ];

    final halo = Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: couleursEffectives),
      ),
    );

    if (disableAnimations) {
      return opaciteStatique == 1.0
          ? halo
          : Opacity(opacity: opaciteStatique, child: halo);
    }

    return halo
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.1, 1.1),
          duration: const Duration(milliseconds: 3000),
          curve: Curves.easeInOut,
        )
        .fade(
          begin: 0.6,
          end: 1,
          duration: const Duration(milliseconds: 3000),
          curve: Curves.easeInOut,
        );
  }
}
