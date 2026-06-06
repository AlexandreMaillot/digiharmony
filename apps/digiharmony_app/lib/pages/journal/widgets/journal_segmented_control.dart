import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/journal/bloc/journal_bloc/journal_bloc.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// SegmentedControl 3 vues : Jour (défaut) / Semaine / Mois.
///
/// Pill arrondi (fond `AppColors.backgroundDeep` contrastant) avec un
/// indicateur unique `AppColors.primary` qui **coulisse** vers l'actif, **sans
/// séparateurs**. Dispatche [JournalVueChangee]. Cibles tactiles ≥ 48dp ;
/// segment actif annoncé (a11y). Glissement coupé en reduced-motion.
class JournalSegmentedControl extends StatelessWidget {
  const JournalSegmentedControl({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vueActive = context.select<JournalBloc, JournalVue>(
      (b) => b.state.vueActive,
    );
    final reduced = MediaQuery.disableAnimationsOf(context);

    final items = <(JournalVue, String)>[
      (JournalVue.jour, l10n.journalSegmentDay),
      (JournalVue.semaine, l10n.journalSegmentWeek),
      (JournalVue.mois, l10n.journalSegmentMonth),
    ];
    final indexActif = items.indexWhere((e) => e.$1 == vueActive);
    // Alignement horizontal de l'indicateur : -1 (gauche) → +1 (droite).
    final alignementX = items.length == 1
        ? 0.0
        : -1 + 2 * indexActif / (items.length - 1);

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        // Piste plus sombre que l'AppBar (`surface`) pour contraster.
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // Indicateur glissant (largeur = 1 segment).
          AnimatedAlign(
            alignment: Alignment(alignementX, 0),
            duration: reduced
                ? Duration.zero
                : const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 1 / items.length,
              heightFactor: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
          ),
          // Libellés tappables par-dessus l'indicateur.
          Row(
            children: [
              for (final (vue, libelle) in items)
                Expanded(
                  child: _Segment(
                    libelle: libelle,
                    actif: vue == vueActive,
                    onTap: () =>
                        context.read<JournalBloc>().add(JournalVueChangee(vue)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Libellé d'un segment (par-dessus l'indicateur glissant).
class _Segment extends StatelessWidget {
  const _Segment({
    required this.libelle,
    required this.actif,
    required this.onTap,
  });

  final String libelle;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: actif,
      label: libelle,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            libelle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: actif ? AppColors.backgroundDeep : AppColors.textMuted,
              fontWeight: actif ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
