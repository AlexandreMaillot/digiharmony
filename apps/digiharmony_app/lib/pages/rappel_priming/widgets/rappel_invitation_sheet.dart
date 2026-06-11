import 'dart:async';

import 'package:digiharmony_app/app/routing/app_router.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/rappel/rappel_bloc.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bottom sheet modale d'invitation one-shot au rappel quotidien (DEC-R-03).
///
/// Affichée une seule fois après la première saisie d'humeur réussie.
/// - CTA principal « Oui, activer » → navigue vers la page priming.
/// - CTA secondaire « Non merci » → ferme la sheet sans rien activer.
///
/// Dispatch [RappelInvitationProposee] AVANT d'afficher la sheet (flag
/// one-shot posé par l'appelant). Ne dispatche PAS elle-même.
class RappelInvitationSheet extends StatelessWidget {
  /// Crée la bottom sheet d'invitation.
  const RappelInvitationSheet({super.key});

  /// Affiche la bottom sheet et retourne quand elle est fermée.
  static Future<void> afficher(BuildContext context) {
    // Dispatch le flag one-shot avant d'ouvrir la sheet.
    context.read<RappelBloc>().add(const RappelInvitationProposee());
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: AppColors.surface,
      builder: (_) => BlocProvider<RappelBloc>.value(
        value: context.read<RappelBloc>(),
        child: const RappelInvitationSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre
            Text(
              l10n.rappelInvitationTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Corps
            Text(
              l10n.rappelInvitationBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // CTA principal : ouvre la page priming (DEC-R-05)
            Semantics(
              button: true,
              label: l10n.rappelInvitationActiverCta,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  unawaited(AppRouter.versRappelPriming(context));
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l10n.rappelInvitationActiverCta),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // CTA secondaire : ferme sans activer
            Semantics(
              button: true,
              label: l10n.rappelInvitationPlusTardCta,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: AppColors.textMuted,
                ),
                child: Text(l10n.rappelInvitationPlusTardCta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
