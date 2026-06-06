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
          // Libellés centraux TAPPABLES « précédent | suivant »
          // (masqués en reduced-motion ; les flèches restent actives).
          if (!disableAnimations)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LienNav(
                    libelle: l10n.conseilsHintPrecedent,
                    actif: aPrecedent,
                    onTap: onPrecedent,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: Text(
                      '|',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textMuted.withValues(alpha: 0.30),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _LienNav(
                    libelle: l10n.conseilsHintSuivant,
                    actif: aSuivant,
                    onTap: onSuivant,
                  ),
                ],
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

/// Libellé de navigation tappable (« précédent » / « suivant »).
///
/// Atténué et non-cliquable lorsque [actif] est faux (bout de deck).
class _LienNav extends StatelessWidget {
  const _LienNav({
    required this.libelle,
    required this.actif,
    required this.onTap,
  });

  final String libelle;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final couleur = AppColors.textMuted.withValues(
      alpha: actif ? 0.55 : 0.25,
    );
    return InkWell(
      onTap: actif ? onTap : null,
      borderRadius: AppRadii.buttonRadius,
      child: ConstrainedBox(
        // Cible tactile a11y >= 48 dp (le texte 13px ne suffit pas seul).
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Center(
            widthFactor: 1,
            child: Text(
              libelle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: couleur,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
