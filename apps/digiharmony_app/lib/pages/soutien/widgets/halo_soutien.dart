import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Halo doux chaud/cyan NON alarmant pour l'ecran de soutien.
///
/// Degrade radial AppColors.primary vers transparent.
/// En mode reduced motion (MediaQuery.disableAnimations), le halo est
/// rendu statique (pas de boucle). Aucun hex en dur. (DEC-SO-009/010)
class HaloSoutien extends StatelessWidget {
  /// Crée le halo de soutien.
  const HaloSoutien({super.key});

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    final halo = Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.primary.withValues(alpha: 0),
          ],
        ),
      ),
    );

    if (disableAnimations) {
      return halo;
    }

    return halo
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1.12, 1.12),
          duration: const Duration(milliseconds: 3200),
          curve: Curves.easeInOut,
        )
        .fade(
          begin: 0.55,
          end: 1,
          duration: const Duration(milliseconds: 3200),
          curve: Curves.easeInOut,
        );
  }
}
