import 'package:digiharmony_app/common/anim/tap_anime.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/locale/locale_bloc.dart';
import 'package:digiharmony_app/pages/parametres/modeles/langue_supportee.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Section de sélection de la langue (cœur fonctionnel de l'écran Paramètres).
///
/// Affiche les 8 langues supportées avec drapeau + endonyme.
/// La langue active est surlignée. Le tap dispatch [LocaleChange] sur le
/// [LocaleBloc] existant (DEC-PARAM-01/02/04).
class SectionLangue extends StatelessWidget {
  /// Crée la section langue.
  const SectionLangue({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.parametresSectionLangue,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, state) {
            // Langue active = locale forcée, ou locale résolue si suivi
            // système (DEC-PARAM-07).
            final codeActif = state.locale?.languageCode ??
                Localizations.localeOf(context).languageCode;

            return Column(
              children: languesSupportees
                  .map(
                    (langue) => _LigneLangue(
                      langue: langue,
                      estActif: langue.code == codeActif,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

/// Ligne de langue individuelle dans la liste.
class _LigneLangue extends StatelessWidget {
  const _LigneLangue({
    required this.langue,
    required this.estActif,
  });

  final LangueSupportee langue;
  final bool estActif;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      selected: estActif,
      label: estActif
          ? '${langue.endonyme} — ${l10n.parametresLangueActiveSemantique}'
          : langue.endonyme,
      child: TapAnime(
        borderRadius: AppRadii.buttonRadius,
        onTap: () => _onTap(context),
        estBouton: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: estActif
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: AppRadii.buttonRadius,
          ),
          child: Row(
            children: [
              Text(
                langue.drapeau,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  langue.endonyme,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ),
              if (estActif)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    // Le haptique est géré par TapAnime (DEC-PARAM-04).
    context.read<LocaleBloc>().add(LocaleChange(Locale(langue.code)));
  }
}
