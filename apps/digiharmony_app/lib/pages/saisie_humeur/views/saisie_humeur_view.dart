import 'dart:async';

import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart';
import 'package:digiharmony_app/pages/saisie_humeur/widgets/carte_feedback_selection.dart';
import 'package:digiharmony_app/pages/saisie_humeur/widgets/picker_emotions.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Vue de l'écran « Noter mon humeur ».
///
/// Contient : header (titre + sous-titre), picker 7 émotions, carte de
/// feedback, footer de réassurance.
///
/// La logique SnackBar (confirmation + undo) et le pop automatique sont gérés
/// ici via [BlocListener] (DEC-SH-005).
class SaisieHumeurView extends StatefulWidget {
  const SaisieHumeurView({super.key});

  @override
  State<SaisieHumeurView> createState() => _SaisieHumeurViewState();
}

class _SaisieHumeurViewState extends State<SaisieHumeurView> {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      _snackBarController;

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
                // Header
                Text(
                  l10n.saisieHumeurTitre,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.saisieHumeurSousTitre,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Picker 7 pastilles
                const PickerEmotions(),
                const SizedBox(height: AppSpacing.lg),
                // Carte de feedback (visible après 1er tap)
                const CarteFeedbackSelection(),
                const Spacer(),
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
      _afficherSnackbarConfirmation(context, state);
    } else if (state is SaisieAnnuleeEtat) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } else if (state is EnregistrementEchoue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _afficherSnackbarConfirmation(
    BuildContext context,
    EnregistrementReussi state,
  ) {
    final l10n = context.l10n;
    final bloc = context.read<SaisieHumeurBloc>();

    _snackBarController?.close();

    _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.saisieHumeurEnregistree),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: l10n.saisieHumeurAnnuler,
          onPressed: () {
            bloc.add(const SaisieAnnulee());
          },
        ),
      ),
    );

    unawaited(_snackBarController!.closed.then(_onSnackBarClosed));
  }

  void _onSnackBarClosed(SnackBarClosedReason reason) {
    if (!mounted) return;
    if (reason != SnackBarClosedReason.action) {
      // Fenêtre undo expirée sans annulation → retour Accueil.
      context.read<SaisieHumeurBloc>().add(const FenetreUndoExpiree());
      Navigator.of(context).pop();
    }
  }
}
