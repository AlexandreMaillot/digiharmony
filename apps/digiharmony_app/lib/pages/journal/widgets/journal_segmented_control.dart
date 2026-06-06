import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/journal/bloc/journal_bloc/journal_bloc.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// SegmentedControl 3 vues : Jour (défaut) / Semaine / Mois.
///
/// Pill arrondi (fond `AppColors.surface`) avec le segment actif surligné par
/// une pastille pleine `AppColors.primary` (texte foncé en gras), **sans
/// séparateurs**. Dispatche [JournalVueChangee]. Cibles tactiles ≥ 48dp ;
/// segment actif annoncé (a11y). Transition désactivée en reduced-motion.
class JournalSegmentedControl extends StatelessWidget {
  const JournalSegmentedControl({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vueActive = context.select<JournalBloc, JournalVue>(
      (b) => b.state.vueActive,
    );

    final items = <(JournalVue, String)>[
      (JournalVue.jour, l10n.journalSegmentDay),
      (JournalVue.semaine, l10n.journalSegmentWeek),
      (JournalVue.mois, l10n.journalSegmentMonth),
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Row(
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
    );
  }
}

/// Un segment du contrôle — surligné en pastille pleine s'il est actif.
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
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      selected: actif,
      label: libelle,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: reduced ? Duration.zero : const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: actif ? AppColors.primary : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
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
