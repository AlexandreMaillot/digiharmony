import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/journal/utils/journal_emotion_utils.dart';
import 'package:digiharmony_app/pages/saisie_humeur/modeles/emotion_canonique.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Bloc « Ce mois-ci » — synthèse descriptive bienveillante.
///
/// - Répartition = comptages SANS classement, ordre fixe d'emotionsCanoniques
///   (DEC-J-07). Aucun tri par fréquence.
/// - Aucune comparaison inter-mois (DEC-J-06/10).
/// - Lignes via journalMonthFrequencyLine (ICU plural).
class JournalSyntheseMois extends StatelessWidget {
  const JournalSyntheseMois({
    required this.entreesDuMois,
    super.key,
  });

  /// Entrées du mois affiché (lecture seule).
  final List<EntreeHumeur> entreesDuMois;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Comptage dans l'ordre fixe d'emotionsCanoniques (DEC-J-07).
    final comptages = <String, int>{};
    for (final e in entreesDuMois) {
      comptages[e.codeEmotion] = (comptages[e.codeEmotion] ?? 0) + 1;
    }

    // Lignes en ordre fixe (jamais trié par fréquence).
    final lignes = emotionsCanoniques
        .where((e) => (comptages[e.cle] ?? 0) > 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.journalMonthSectionTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (lignes.isEmpty)
          Text(
            l10n.journalMonthSummaryEmpty,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
          )
        else ...[
          // Répartition en ordre fixe (DEC-J-07).
          for (final emotion in lignes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                l10n.journalMonthFrequencyLine(
                  libelleEmotion(l10n, emotion.cle),
                  comptages[emotion.cle]!,
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          // Tendance descriptive bienveillante (pas de comparaison — DEC-J-06).
          Text(
            l10n.journalMonthSummary,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}
