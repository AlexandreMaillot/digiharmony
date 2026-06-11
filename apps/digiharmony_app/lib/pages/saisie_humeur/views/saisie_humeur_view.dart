import 'dart:async';

import 'package:digiharmony_app/app/view/app.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/rappel_priming/widgets/rappel_invitation_sheet.dart';
import 'package:digiharmony_app/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart';
import 'package:digiharmony_app/pages/saisie_humeur/widgets/carte_feedback_selection.dart';
import 'package:digiharmony_app/pages/saisie_humeur/widgets/picker_emotions.dart';
import 'package:digiharmony_app/rappel/rappel_bloc.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Vue de l'écran « Noter mon humeur ».
///
/// Contient : header (titre + sous-titre), picker 7 émotions, carte de
/// feedback, bouton « Valider », footer de réassurance.
///
/// Flux (DEC-SH-008) : la sélection est purement visuelle ; l'enregistrement
/// Drift n'a lieu qu'au tap sur « Valider », qui referme l'écran et revient à
/// l'Accueil. Le pop au succès est géré ici via [BlocListener].
class SaisieHumeurView extends StatelessWidget {
  const SaisieHumeurView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<SaisieHumeurBloc, SaisieHumeurState>(
      listener: _onStateChange,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            // Écran de tâche poussé sur la bottom bar : on ferme (X),
            // on ne « revient » pas (DEC-NAV-2026).
            icon: const Icon(Icons.close),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Image.asset(
            'assets/images/logo_digiharmony_square.png',
            height: 32,
          ),
          centerTitle: true,
          // Équilibre visuel : SizedBox de même largeur que le leading (48 px)
          // pour que le logo reste centré sans bouton de droite superflu.
          actions: const [SizedBox(width: 48)],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Contenu défilable : absorbe les pastilles agrandies + la
                // carte de feedback sur les petits écrans (anti-overflow).
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Text(
                          l10n.saisieHumeurTitre,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.saisieHumeurSousTitre,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        // Picker 7 pastilles
                        const PickerEmotions(),
                        const SizedBox(height: AppSpacing.lg),
                        // Carte de feedback (visible après 1re sélection)
                        const CarteFeedbackSelection(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Bouton de validation (enregistre + retour Accueil)
                const _BoutonValider(),
                const SizedBox(height: AppSpacing.md),
                // Footer de réassurance
                Text(
                  l10n.saisieHumeurDonneesLocales,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onStateChange(BuildContext context, SaisieHumeurState state) {
    if (state is EnregistrementReussi) {
      unawaited(HapticFeedback.mediumImpact());
      // Invitation one-shot au rappel (DEC-R-03) : affiche la sheet si le flag
      // n'a pas encore été posé. Le RappelBloc est app-level (fourni via App).
      // Lecture optionnelle : si absent (test sans RappelBloc), on ignore.
      RappelBloc? rappelBlocNullable;
      try {
        rappelBlocNullable = context.read<RappelBloc>();
      } on Object {
        rappelBlocNullable = null;
      }
      final rappelBloc = rappelBlocNullable;
      final montrerInvitation =
          rappelBloc != null && !rappelBloc.state.invitationDejaProposee;

      // Replanification après saisie (DEC-R-04) — humeurDuJourEstNotee sera
      // true désormais, la prochaine notif est donc replanifiée pour demain.
      rappelBloc?.add(const RappelReplanificationDemandee());

      // Retour à l'Accueil : la carte humeur s'y met à jour via Drift watch().
      Navigator.of(context).pop();

      if (montrerInvitation) {
        // La sheet dispatche elle-même [RappelInvitationProposee] avant de
        // s'afficher (one-shot garanti par [RappelInvitationSheet.afficher]).
        // La sheet est affichée sur l'écran parent (AccueilView) via le
        // navigateur global (appNavigatorKey) — au post-frame pour laisser la
        // transition de route se terminer proprement (DEC-R-03).
        SchedulerBinding.instance.addPostFrameCallback((_) {
          final nav = appNavigatorKey.currentState;
          if (nav != null) {
            unawaited(
              RappelInvitationSheet.afficher(nav.context),
            );
          }
        });
      }
    } else if (state is EnregistrementEchoue) {
      // Message i18n bienveillant (public mineur) plutôt que l'exception brute.
      // `state.message` reste disponible pour usage interne/diagnostic.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.saisieHumeurErreur),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

/// Bouton primaire « Valider » : actif dès qu'une émotion est sélectionnée,
/// affiche un indicateur pendant l'enregistrement.
class _BoutonValider extends StatelessWidget {
  const _BoutonValider();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<SaisieHumeurBloc, SaisieHumeurState>(
      builder: (context, state) {
        final enCours = state is EnregistrementEnCours;
        final actif = state.codeSelectionne != null && !enCours;

        return FilledButton(
          onPressed: actif
              ? () =>
                    context.read<SaisieHumeurBloc>().add(const SaisieValidee())
              : null,
          child: enCours
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.saisieHumeurValider),
        );
      },
    );
  }
}
