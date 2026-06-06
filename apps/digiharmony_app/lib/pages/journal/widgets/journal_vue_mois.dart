import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/journal/bloc/journal_bloc/journal_bloc.dart';
import 'package:digiharmony_app/pages/journal/widgets/journal_calendrier_mois.dart';
import 'package:digiharmony_app/pages/journal/widgets/journal_synthese_mois.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Vue Mois : calendrier borné au passé + synthèse Ce mois-ci.
///
/// - Flèche suivant désactivée si `!peutAvancerMois` (DEC-J-05).
/// - Aucun mois futur accessible.
/// - Synthèse : comptages ordre fixe emotionsCanoniques, aucune comparaison
///   inter-mois (DEC-J-06/07/10).
class JournalVueMois extends StatelessWidget {
  const JournalVueMois({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<JournalBloc>().state;
    final mois = state.moisAffiche;
    final peutAvancer = state.peutAvancerMois;
    final entrees = state.entreesMois;
    final locale = Localizations.localeOf(context).toString();

    final libellemois = DateFormat.yMMMM(locale).format(mois);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête navigation mois.
          Row(
            children: [
              // Flèche précédent.
              Semantics(
                label: l10n.journalMonthPrevTooltip,
                button: true,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    tooltip: l10n.journalMonthPrevTooltip,
                    onPressed: () => context.read<JournalBloc>().add(
                      const JournalMoisPrecedent(),
                    ),
                  ),
                ),
              ),
              // Libellé mois/année.
              Expanded(
                child: Text(
                  libellemois,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              // Flèche suivant (désactivée au mois courant — DEC-J-05).
              Semantics(
                label: l10n.journalMonthNextTooltip,
                button: true,
                enabled: peutAvancer,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: l10n.journalMonthNextTooltip,
                    // null désactive le bouton (grisé automatiquement).
                    onPressed: peutAvancer
                        ? () => context.read<JournalBloc>().add(
                            const JournalMoisSuivant(),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Grille calendrier.
          JournalCalendrierMois(
            moisAffiche: mois,
            entreesDuMois: entrees,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Synthèse « Ce mois-ci » (DEC-J-06/07).
          JournalSyntheseMois(entreesDuMois: entrees),
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
}
