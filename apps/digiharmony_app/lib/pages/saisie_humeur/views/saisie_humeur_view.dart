import 'dart:async';

import 'package:digiharmony_app/common/anim/entree_douce.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart';
import 'package:digiharmony_app/pages/saisie_humeur/widgets/carte_feedback_selection.dart';
import 'package:digiharmony_app/pages/saisie_humeur/widgets/picker_emotions.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
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
            icon: const Icon(Icons.chevron_left),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
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
                        // index 0 — Header
                        EntreeDouce(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.saisieHumeurTitre,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: AppColors.primary),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                l10n.saisieHumeurSousTitre,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        // index 1 — Picker 7 pastilles
                        // Les pastilles ont déjà leurs propres animations ;
                        // on enrobe juste l'entrée du groupe.
                        const EntreeDouce(
                          index: 1,
                          child: PickerEmotions(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // index 2 — Carte de feedback (après 1re sélection)
                        const EntreeDouce(
                          index: 2,
                          child: CarteFeedbackSelection(),
                        ),
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
      // Retour à l'Accueil : la carte humeur s'y met à jour via Drift watch().
      Navigator.of(context).pop();
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
