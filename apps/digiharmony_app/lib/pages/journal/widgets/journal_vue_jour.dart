import 'package:digiharmony_app/app/routing/app_router.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/journal/bloc/journal_bloc/journal_bloc.dart';
import 'package:digiharmony_app/pages/journal/widgets/journal_carte_jour.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Vue Jour : carte du jour OU état vide bienveillant + conseil toujours
/// affiché (DEC-J-01/04).
class JournalVueJour extends StatelessWidget {
  const JournalVueJour({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<JournalBloc>().state;
    final humeur = state.humeurDuJour;
    final conseilCle = state.conseilDuJourCle;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: humeur != null && conseilCle != null
          ? JournalCarteJour(humeur: humeur, conseilCle: conseilCle)
          : _EtatVideBienveillant(conseilCle: conseilCle),
    );
  }
}

/// État vide bienveillant quand aucune humeur n'est notée aujourd'hui
/// (DEC-J-04). Le conseil reste toujours affiché.
class _EtatVideBienveillant extends StatelessWidget {
  const _EtatVideBienveillant({this.conseilCle});

  final String? conseilCle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.journalDayEmptyTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.journalDayEmptyBody,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            // Conseil du jour (toujours visible — DEC-J-04).
            if (conseilCle != null) ...[
              const SizedBox(height: AppSpacing.lg),
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
                          _texteConseil(l10n, conseilCle!),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            // CTA vers saisie humeur (DEC-J-03).
            ElevatedButton(
              onPressed: () => AppRouter.versSaisieHumeur(context),
              child: Text(l10n.journalDayEmptyCta),
            ),
          ],
        ),
      ),
    );
  }

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
