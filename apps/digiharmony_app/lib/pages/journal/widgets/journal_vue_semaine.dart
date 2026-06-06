import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/journal/bloc/journal_bloc/journal_bloc.dart';
import 'package:digiharmony_app/pages/saisie_humeur/modeles/emotion_canonique.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Vue Semaine : bande 7 jours lundi→dimanche + résumé descriptif neutre.
///
/// - Locale-aware (DateFormat.E).
/// - Pastilles via emojiPourCode + MoodColors (jamais en dur).
/// - Résumé journalWeekSummary/{count} ou journalWeekSummaryEmpty.
/// - Aucun score, aucun classement (DEC-J-10/07).
class JournalVueSemaine extends StatelessWidget {
  const JournalVueSemaine({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<JournalBloc>().state;
    final entrees = state.entreesSemaine;

    // Lundi de la semaine courante (basé sur DateTime.now()).
    final maintenant = DateTime.now();
    final lundi = _lundiDeLaSemaine(maintenant);

    // Indexation par `jour` (garantie unique).
    final parJour = <DateTime, EntreeHumeur>{};
    for (final e in entrees) {
      parJour[e.jour] = e;
    }

    final locale = Localizations.localeOf(context).toString();
    final nbNotes = parJour.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.journalWeekTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          // Bande 7 jours.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final jour = lundi.add(Duration(days: i));
              final entree = parJour[jour];
              return _CaseJour(
                jour: jour,
                entree: entree,
                locale: locale,
                aucuneEntreeLabel: l10n.journalWeekNoEntry,
              );
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          // Résumé descriptif (aucun classement/score — DEC-J-10).
          Text(
            nbNotes > 0
                ? l10n.journalWeekSummary(nbNotes)
                : l10n.journalWeekSummaryEmpty,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Note zéro-collecte (COULD).
          Text(
            l10n.journalLocalDataNote,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Lundi de la semaine contenant [date].
  static DateTime _lundiDeLaSemaine(DateTime date) {
    final normalise = DateTime(date.year, date.month, date.day);
    return normalise.subtract(Duration(days: normalise.weekday - 1));
  }
}

/// Case d'un jour dans la bande semaine.
class _CaseJour extends StatelessWidget {
  const _CaseJour({
    required this.jour,
    required this.entree,
    required this.locale,
    required this.aucuneEntreeLabel,
  });

  final DateTime jour;
  final EntreeHumeur? entree;
  final String locale;
  final String aucuneEntreeLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final etiquette = DateFormat.E(locale).format(jour);
    final code = entree?.codeEmotion;
    final emoji = code != null ? emojiPourCode(code) : null;
    final couleur = code != null ? MoodColors.byKey[code] : null;
    final humeurLabel = code != null ? libelleEmotion(l10n, code) : null;

    return Semantics(
      label: humeurLabel != null ? '$etiquette: $humeurLabel' : etiquette,
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: code != null
                ? Container(
                    decoration: BoxDecoration(
                      color: (couleur ?? AppColors.primary).withValues(
                        alpha: 0.18,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        emoji!.isNotEmpty ? emoji : code,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      aucuneEntreeLabel,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 2),
          Text(
            etiquette,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
