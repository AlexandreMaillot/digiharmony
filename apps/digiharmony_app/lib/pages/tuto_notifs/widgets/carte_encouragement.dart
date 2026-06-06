import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Carte d'encouragement : icône soleil or + message bienveillant.
class CarteEncouragement extends StatelessWidget {
  /// Crée la carte d'encouragement.
  const CarteEncouragement({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.button)),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wb_sunny_outlined, color: AppColors.accentGold),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              l10n.tutoNotifsEncouragement,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
