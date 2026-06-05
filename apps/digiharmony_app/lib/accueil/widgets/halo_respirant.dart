import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Halo en fond, respire en boucle via flutter_animate.
///
/// a11y : si `MediaQuery.disableAnimations` est vrai, le halo est rendu
/// statique (RM-1 — DEC-HOME-07).
class HaloRespirant extends StatelessWidget {
  /// Crée un halo respirant.
  const HaloRespirant({super.key});

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    final halo = Container(
      width: 340,
      height: 340,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.signatureGradient[1].withValues(alpha: 0.08),
            AppColors.background.withValues(alpha: 0),
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
