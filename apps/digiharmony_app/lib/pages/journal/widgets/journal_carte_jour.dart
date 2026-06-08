import 'package:digiharmony_app/app/routing/app_router.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/saisie_humeur/modeles/emotion_canonique.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Carte du jour avec humeur, conseil et CTAs (DEC-J-02/03/09).
///
/// - Emoji et couleur via [emojiPourCode] + [MoodColors.byKey] (jamais en dur).
/// - CTA exercice = STUB → SnackBar journalExerciseComingSoon (DEC-J-02).
/// - Lien « Modifier » → AppRouter.versSaisieHumeur (DEC-J-03).
class JournalCarteJour extends StatelessWidget {
  const JournalCarteJour({
    required this.humeur,
    required this.conseilCle,
    super.key,
  });

  /// Humeur du jour (non null dans ce widget).
  final EntreeHumeur humeur;

  /// Clé i18n du conseil du jour (ex. `tipDay01`).
  final String conseilCle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final code = humeur.codeEmotion;
    final emoji = emojiPourCode(code);
    final couleur = MoodColors.byKey[code];
    final libelleHumeur = libelleEmotion(l10n, code);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Pastille émotion + libellé.
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Semantics(
                      label: libelleHumeur,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: (couleur ?? AppColors.primary).withValues(
                            alpha: 0.18,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            emoji.isNotEmpty ? emoji : code,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.journalDayMoodPrefix,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                          Text(
                            libelleHumeur,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: couleur ?? AppColors.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Conseil du jour.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.accentGold,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.journalDayTipLabel,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            _texteConseil(l10n, conseilCle),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // CTA exercice (STUB V1 — DEC-J-02).
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.journalExerciseComingSoon),
                        ),
                      );
                    },
                    child: Text(l10n.journalDayDoExerciseCta),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Lien modifier (DEC-J-03).
                Center(
                  child: TextButton(
                    onPressed: () => AppRouter.versSaisieHumeur(context),
                    child: Text(l10n.journalDayEditMoodLink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Résout le texte du conseil depuis sa clé i18n.
  String _texteConseil(AppLocalizations l10n, String cle) {
    switch (cle) {
      case 'tipDay01':
        return l10n.tipDay01;
      case 'tipDay02':
        return l10n.tipDay02;
      case 'tipDay03':
        return l10n.tipDay03;
      case 'tipDay04':
        return l10n.tipDay04;
      case 'tipDay05':
        return l10n.tipDay05;
      case 'tipDay06':
        return l10n.tipDay06;
      case 'tipDay07':
        return l10n.tipDay07;
      default:
        return cle;
    }
  }
}
