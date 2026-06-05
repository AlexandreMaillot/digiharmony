import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Halo dégradé radial « respirant » derrière le logo.
///
/// En mode normal : scale ~0.9↔1.1 + opacité ~0.4↔0.8 en boucle
/// (`flutter_animate`). Si [animer] est `false` (reduced motion, DEC-S-005),
/// le halo est affiché dans un état de repos **statique** (aucune boucle).
class HaloRespirant extends StatelessWidget {
  /// Crée le halo respirant. [animer] pilote la boucle d'animation.
  const HaloRespirant({required this.animer, super.key});

  /// Active la boucle de respiration (désactivée en reduced motion).
  final bool animer;

  @override
  Widget build(BuildContext context) {
    final halo = Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0),
          ],
        ),
      ),
    );

    if (!animer) {
      return Opacity(opacity: 0.5, child: halo);
    }

    return halo
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 0.9,
          end: 1.1,
          duration: 2400.ms,
          curve: Curves.easeInOut,
        )
        .fadeIn(begin: 0.4, duration: 2400.ms);
  }
}
