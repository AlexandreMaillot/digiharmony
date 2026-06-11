import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Pilule « Faire une pause » avec animation breathing en boucle.
///
/// a11y : si `MediaQuery.disableAnimations` est vrai, la respiration est
/// désactivée (RM-3 — DEC-HOME-07).
///
/// Le haptique est délégué au [onTap] appelant (ex. via `ouvrirPlaceholder`).
class PiluleAction extends StatelessWidget {
  /// Crée la pilule d'action.
  const PiluleAction({
    required this.label,
    required this.icone,
    required this.onTap,
    this.accent = AppColors.primary,
    super.key,
  });

  /// Libellé de la pilule.
  final String label;

  /// Icône Material.
  final IconData icone;

  /// Callback au tap — le haptique est géré par l'appelant.
  final VoidCallback onTap;

  /// Couleur d'accent de la pilule (dégradé, icône, libellé, bordure).
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    const rayon = BorderRadius.all(Radius.circular(AppSpacing.xl));

    final pilule = Material(
      color: Colors.transparent,
      borderRadius: rayon,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: rayon,
          gradient: LinearGradient(
            colors: [
              Color.alphaBlend(
                accent.withValues(alpha: 0.50),
                AppColors.surfaceBright,
              ),
              Color.alphaBlend(
                accent.withValues(alpha: 0.28),
                AppColors.surfaceBright,
              ),
            ],
          ),
          border: Border.all(color: accent.withValues(alpha: 0.60)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: rayon,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icone, color: accent, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (disableAnimations) return pilule;

    return pilule
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.04, 1.04),
          duration: const Duration(milliseconds: 2000),
          curve: Curves.easeInOut,
        );
  }
}
