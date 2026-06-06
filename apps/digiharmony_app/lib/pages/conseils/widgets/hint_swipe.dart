import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Barre de navigation bas-de-deck : flèches tap visibles (≥ 48dp) + hint.
///
/// Satisfait DEC-CO-08 (swipe accessible) : la navigation est possible
/// **sans geste** via les zones tap « ‹ précédent » / « suivant › » qui
/// déclenchent [onPrecedent]/[onSuivant]. Les `customSemanticsActions` du
/// parent sont conservées pour les lecteurs d'écran.
///
/// En reduced-motion, le hint textuel atténué est masqué mais les flèches
/// restent visibles et actives. Flèche désactivée (couleur réduite) si on
/// est en bout de deck ([aPrecedent]/[aSuivant] = false).
class HintSwipe extends StatelessWidget {
  /// Crée la barre de navigation swipe/flèches.
  const HintSwipe({
    required this.onPrecedent,
    required this.onSuivant,
    this.aPrecedent = true,
    this.aSuivant = true,
    this.visible = true,
    this.disableAnimations = false,
    super.key,
  });

  /// Callback déclenché quand l'utilisateur tape sur la flèche ‹ précédent.
  final VoidCallback onPrecedent;

  /// Callback déclenché quand l'utilisateur tape sur la flèche › suivant.
  final VoidCallback onSuivant;

  /// Vrai si une carte précédente existe (sinon flèche atténuée).
  final bool aPrecedent;

  /// Vrai si une carte suivante existe (sinon flèche atténuée).
  final bool aSuivant;

  /// Si faux, tout le widget est invisible (carte unique ou état non-pret).
  final bool visible;

  /// Si vrai (reduced-motion), masque le hint textuel mais garde les flèches.
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flèche précédent (≥ 48dp tap target)
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: l10n.conseilsHintPrecedent,
              color: aPrecedent
                  ? AppColors.textMuted
                  : AppColors.textMuted.withValues(alpha: 0.25),
              onPressed: aPrecedent ? onPrecedent : null,
            ),
          ),
          // Hint textuel central (masqué en reduced-motion)
          if (!disableAnimations)
            Expanded(
              child: Text(
                '${l10n.conseilsHintPrecedent}  |  ${l10n.conseilsHintSuivant}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMuted.withValues(alpha: 0.45),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            const Expanded(child: SizedBox.shrink()),
          // Flèche suivant (≥ 48dp tap target)
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: l10n.conseilsHintSuivant,
              color: aSuivant
                  ? AppColors.textMuted
                  : AppColors.textMuted.withValues(alpha: 0.25),
              onPressed: aSuivant ? onSuivant : null,
            ),
          ),
        ],
      ),
    );
  }
}
