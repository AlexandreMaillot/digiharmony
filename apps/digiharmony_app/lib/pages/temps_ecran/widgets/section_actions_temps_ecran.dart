import 'package:digiharmony_app/app/routing/app_router.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Carte « confidentialité » (bouclier + message) — partagée iOS / Android.
///
/// Le message diffère par plateforme : Android = données locales jamais
/// envoyées ; iOS = l'app ne voit même pas les chiffres (rendus par le
/// système). D'où le paramètre [message].
class CarteConfidentialiteTempsEcran extends StatelessWidget {
  /// Crée la carte avec le [message] de confidentialité à afficher.
  const CarteConfidentialiteTempsEcran({required this.message, super.key});

  /// Texte de confidentialité (résolu depuis l'ARB par l'appelant).
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section « ET MAINTENANT ? » + 2 cartes d'action (Détox / couper notifs).
///
/// Partagée iOS / Android : ce sont des **actions Flutter** (navigation), pas
/// des données — donc identiques sur les deux plateformes.
class SectionActionsTempsEcran extends StatelessWidget {
  /// Crée la section d'actions.
  const SectionActionsTempsEcran({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.tempsEcranEtMaintenant,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _CarteAction(
          icone: Icons.spa_outlined,
          titre: l10n.tempsEcranFairePause,
          sousTitre: l10n.tempsEcranFairePauseSousTitre,
          onTap: () => AppRouter.versDetox(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        _CarteAction(
          icone: Icons.notifications_off_outlined,
          titre: l10n.tempsEcranCouperNotifs,
          sousTitre: l10n.tempsEcranCouperNotifsSousTitre,
          onTap: () => AppRouter.versTutoNotifs(context),
        ),
      ],
    );
  }
}

/// Carte d'action : pastille icône + titre + sous-titre + chevron.
class _CarteAction extends StatelessWidget {
  const _CarteAction({
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.onTap,
  });

  final IconData icone;
  final String titre;
  final String sousTitre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Pastille icône cyan.
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              // Textes.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sousTitre,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
