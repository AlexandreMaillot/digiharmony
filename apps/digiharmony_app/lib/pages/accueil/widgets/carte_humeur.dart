import 'dart:async';

import 'package:digiharmony_app/app/routing/app_router.dart';
import 'package:digiharmony_app/app/shell/main_shell.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/accueil/bloc/accueil_bloc.dart';
import 'package:digiharmony_app/pages/saisie_humeur/modeles/emotion_canonique.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

/// Carte héroïque à 2 états pilotés par Drift.
///
/// - État A : [humeur] == null → invitation à noter l'humeur.
/// - État B : [humeur] != null → résumé de l'humeur du jour.
/// - Fallback : [erreur] == true → rendu État A (AC7).
class CarteHumeur extends StatelessWidget {
  /// Crée la carte avec l'humeur optionnelle du jour.
  const CarteHumeur({
    required this.conseil,
    this.humeur,
    this.erreur = false,
    super.key,
  });

  /// Humeur du jour (null → État A).
  final HumeurDuJourVue? humeur;

  /// Conseil du jour (affiché en État A et B).
  final ConseilDuJourVue conseil;

  /// Si vrai, l'UI rend l'État A en fallback silencieux.
  final bool erreur;

  @override
  Widget build(BuildContext context) {
    final effectiveHumeur = erreur ? null : humeur;
    return effectiveHumeur == null
        ? _CarteEtatA(conseil: conseil)
        : _CarteEtatB(humeur: effectiveHumeur, conseil: conseil);
  }
}

/// Carte HeroCard — État A (aucune entrée aujourd'hui).
class _CarteEtatA extends StatelessWidget {
  const _CarteEtatA({required this.conseil});

  final ConseilDuJourVue conseil;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _CarteColoree(
      accent: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite_border, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.heroMoodQuestion,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.heroMoodInvite,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => AppRouter.versSaisieHumeur(context),
                icon: const Icon(Icons.add_circle_outline),
                label: Text(l10n.heroLogMoodCta),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: () => _ouvrirJournal(context),
                child: Text(l10n.heroSeeJournal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte HeroCard — État B (humeur déjà notée aujourd'hui).
class _CarteEtatB extends StatelessWidget {
  const _CarteEtatB({required this.humeur, required this.conseil});

  final HumeurDuJourVue humeur;
  final ConseilDuJourVue conseil;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final heureFormatee = DateFormat.Hm(
      locale.toString(),
    ).format(humeur.noteeLe);
    final couleurEmotion = MoodColors.byKey[humeur.codeEmotion];
    final libelle = libelleEmotion(l10n, humeur.codeEmotion);

    return _CarteColoree(
      accent: couleurEmotion ?? AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (couleurEmotion != null)
                  _PastilleEmoji(emoji: humeur.emoji, couleur: couleurEmotion)
                else
                  Text(humeur.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.heroMoodTodayPrefix,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        libelle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: couleurEmotion ?? AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.heroMoodLoggedAt(heureFormatee),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: TextButton(
                onPressed: () => _ouvrirJournal(context),
                child: Text(l10n.heroSeeJournal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ouvre le Journal, qui est un onglet de la bottom bar.
///
/// Sous [MainShell] : bascule l'onglet Journal (pas d'empilement, pas de
/// retour — DEC-NAV-2026). Hors shell (prévisualisation, tests) : retombe sur
/// l'ancienne navigation empilée.
void _ouvrirJournal(BuildContext context) {
  final shell = ShellScope.maybeOf(context);
  if (shell != null) {
    shell.allerVers(OngletPrincipal.journal);
  } else {
    unawaited(AppRouter.versJournal(context));
  }
}

/// Pastille emoji d'humeur agrandie, avec un léger rebond (reduced-motion ok).
class _PastilleEmoji extends StatelessWidget {
  const _PastilleEmoji({required this.emoji, required this.couleur});

  final String emoji;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final pastille = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.22),
        shape: BoxShape.circle,
        border: Border.all(color: couleur.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 26)),
      ),
    );
    if (reduce) return pastille;
    return pastille
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.12, 1.12),
          duration: const Duration(milliseconds: 1400),
          curve: Curves.easeInOut,
        );
  }
}

/// Conteneur de carte héroïque teinté par une couleur d'[accent].
///
/// Dégradé doux (accent → surface) + bordure fine, pour donner de la vie à la
/// carte sans sortir du design system « Navy & Halo ». L'accent reflète
/// l'émotion du jour (État B) ou le cyan primaire (État A).
class _CarteColoree extends StatelessWidget {
  const _CarteColoree({required this.accent, required this.child});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadii.cardRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              accent.withValues(alpha: 0.40),
              AppColors.surfaceBright,
            ),
            AppColors.surfaceBright,
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
