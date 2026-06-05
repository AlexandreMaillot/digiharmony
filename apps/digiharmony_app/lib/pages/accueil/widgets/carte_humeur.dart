import 'package:digiharmony_app/common/placeholder_screen.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/accueil/bloc/accueil_bloc.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
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
    return Card(
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
                onPressed: () =>
                    ouvrirPlaceholder(context, l10n.placeholderNoterHumeur),
                icon: const Icon(Icons.add_circle_outline),
                label: Text(l10n.heroLogMoodCta),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: () =>
                    ouvrirPlaceholder(context, l10n.placeholderJournal),
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
    final libelle = _libelleEmotion(context, humeur.codeEmotion);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (couleurEmotion != null)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: couleurEmotion.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        humeur.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                else
                  Text(humeur.emoji, style: const TextStyle(fontSize: 28)),
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
                onPressed: () =>
                    ouvrirPlaceholder(context, l10n.placeholderJournal),
                child: Text(l10n.heroSeeJournal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Résout le libellé localisé depuis le [codeEmotion].
  String _libelleEmotion(BuildContext context, String codeEmotion) {
    final l10n = context.l10n;
    switch (codeEmotion) {
      case 'happy':
        return l10n.moodHappy;
      case 'calm':
        return l10n.moodCalm;
      case 'dynamic':
        return l10n.moodDynamic;
      case 'sad':
        return l10n.moodSad;
      case 'angry':
        return l10n.moodAngry;
      case 'nervous':
        return l10n.moodNervous;
      case 'tired':
        return l10n.moodTired;
      default:
        // Fallback gracieux pour code inconnu (HC-6).
        return codeEmotion;
    }
  }
}
