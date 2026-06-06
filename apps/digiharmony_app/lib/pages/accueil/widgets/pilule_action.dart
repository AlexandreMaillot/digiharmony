import 'dart:async';

import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    super.key,
  });

  /// Libellé de la pilule.
  final String label;

  /// Icône Material.
  final IconData icone;

  /// Callback au tap — le haptique est géré par l'appelant.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    final pilule = Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.xl)),
      child: InkWell(
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          onTap();
        },
        borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.xl)),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
