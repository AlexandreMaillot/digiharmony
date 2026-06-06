import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/journal/bloc/journal_bloc/journal_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// SegmentedControl 3 vues : Jour (défaut) / Semaine / Mois.
///
/// Dispatche [JournalVueChangee] au Bloc. Cibles tactiles ≥ 48dp. Sémantique
/// segment actif annoncée (a11y).
class JournalSegmentedControl extends StatelessWidget {
  const JournalSegmentedControl({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vueActive = context.select<JournalBloc, JournalVue>(
      (b) => b.state.vueActive,
    );

    final segments = <JournalVue, Widget>{
      JournalVue.jour: Semantics(
        label: l10n.journalSegmentDay,
        selected: vueActive == JournalVue.jour,
        child: Text(l10n.journalSegmentDay),
      ),
      JournalVue.semaine: Semantics(
        label: l10n.journalSegmentWeek,
        selected: vueActive == JournalVue.semaine,
        child: Text(l10n.journalSegmentWeek),
      ),
      JournalVue.mois: Semantics(
        label: l10n.journalSegmentMonth,
        selected: vueActive == JournalVue.mois,
        child: Text(l10n.journalSegmentMonth),
      ),
    };

    return SizedBox(
      height: 48,
      child: SegmentedButton<JournalVue>(
        segments: segments.entries
            .map(
              (e) => ButtonSegment<JournalVue>(
                value: e.key,
                label: e.value,
              ),
            )
            .toList(),
        selected: {vueActive},
        onSelectionChanged: (selection) {
          if (selection.isNotEmpty) {
            context.read<JournalBloc>().add(JournalVueChangee(selection.first));
          }
        },
        showSelectedIcon: false,
      ),
    );
  }
}
