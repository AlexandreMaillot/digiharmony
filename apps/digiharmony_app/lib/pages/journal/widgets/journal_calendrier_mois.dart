import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/journal/utils/journal_emotion_utils.dart';
import 'package:digiharmony_app/pages/saisie_humeur/modeles/emotion_canonique.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Grille calendrier mensuel.
///
/// - Jours notés → emoji (via emojiPourCode, jamais en dur).
/// - Jours non notés → numéro grisé (AppColors.textMuted).
/// - Jours hors mois → vides.
/// - Aucune navigation vers le futur (grille passive).
/// - En-têtes de colonnes locale-aware via DateFormat (jamais de chaînes FR).
class JournalCalendrierMois extends StatelessWidget {
  const JournalCalendrierMois({
    required this.moisAffiche,
    required this.entreesDuMois,
    super.key,
  });

  /// Premier jour du mois affiché.
  final DateTime moisAffiche;

  /// Entrées du mois (au plus 1 par jour).
  final List<EntreeHumeur> entreesDuMois;

  @override
  Widget build(BuildContext context) {
    // Indexation par numéro de jour du mois.
    final parJour = <int, EntreeHumeur>{};
    for (final e in entreesDuMois) {
      parJour[e.jour.day] = e;
    }

    // Nombre de jours dans le mois.
    final nbJours = DateUtils.getDaysInMonth(
      moisAffiche.year,
      moisAffiche.month,
    );
    // Premier jour du mois (1 = lundi, 7 = dimanche).
    final premierJourSemaine = moisAffiche.weekday;
    // Décalage de colonnes (lundi = index 0).
    final decalage = premierJourSemaine - 1;

    // En-têtes locale-aware, lundi-first (index 0 = lundi = weekday 1).
    final locale = Localizations.localeOf(context).toString();
    // Référence : semaine contenant un lundi connu (2024-01-01 = lundi).
    // ignore: avoid_redundant_argument_values
    final lundiRef = DateTime(2024, 1, 1);
    final etiquetteJours = List.generate(
      7,
      (i) => DateFormat('EEEEE', locale).format(
        lundiRef.add(Duration(days: i)),
      ),
    );

    final cellules = <Widget>[];

    // En-têtes de colonnes.
    for (final e in etiquetteJours) {
      cellules.add(
        Center(
          child: Text(
            e,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Cases vides de décalage.
    for (var i = 0; i < decalage; i++) {
      cellules.add(const SizedBox.shrink());
    }

    // Cases pour chaque jour du mois.
    for (var jour = 1; jour <= nbJours; jour++) {
      final entree = parJour[jour];
      cellules.add(_CaseCalendrier(jour: jour, entree: entree));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 2,
      children: cellules,
    );
  }
}

/// Une case du calendrier mensuel.
class _CaseCalendrier extends StatelessWidget {
  const _CaseCalendrier({required this.jour, this.entree});

  final int jour;
  final EntreeHumeur? entree;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final code = entree?.codeEmotion;
    final emoji = code != null ? emojiPourCode(code) : null;
    final couleur = code != null ? MoodColors.byKey[code] : null;
    final humeurLabel = code != null ? libelleEmotion(l10n, code) : null;

    return Semantics(
      label: humeurLabel != null
          ? l10n.journalCalendarDayMoodSemantics(jour, humeurLabel)
          : l10n.journalCalendarDaySemantics(jour),
      child: SizedBox(
        width: 40,
        height: 40,
        child: code != null
            ? Container(
                decoration: BoxDecoration(
                  color: (couleur ?? AppColors.primary).withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    emoji!.isNotEmpty ? emoji : code,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              )
            : Center(
                child: Text(
                  '$jour',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
      ),
    );
  }
}
