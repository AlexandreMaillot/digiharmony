import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/journal/bloc/journal_bloc/journal_bloc.dart';
import 'package:digiharmony_app/pages/journal/widgets/journal_segmented_control.dart';
import 'package:digiharmony_app/pages/journal/widgets/journal_vue_jour.dart';
import 'package:digiharmony_app/pages/journal/widgets/journal_vue_mois.dart';
import 'package:digiharmony_app/pages/journal/widgets/journal_vue_semaine.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Scaffold principal du journal.
///
/// - Toolbar haute : retour · titre.
/// - SegmentedControl : Jour / Semaine / Mois.
/// - Contenu : switch de vue selon [JournalVue].
class JournalView extends StatelessWidget {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vueActive = context.select<JournalBloc, JournalVue>(
      (b) => b.state.vueActive,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.journalTitle),
        automaticallyImplyLeading: false,
        // Onglet de la bottom bar : pas de retour (DEC-NAV-2026). Le chevron
        // ne réapparaît qu'en navigation empilée (prévisualisation/tests).
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: JournalSegmentedControl(),
          ),
        ),
      ),
      body: switch (vueActive) {
        JournalVue.jour => const JournalVueJour(),
        JournalVue.semaine => const JournalVueSemaine(),
        JournalVue.mois => const JournalVueMois(),
      },
    );
  }
}
