import 'dart:async';

import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/temps_ecran/bloc/temps_ecran_bloc.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Écran d'explication iOS AVANT la demande FamilyControls (DEC-TE-15).
///
/// - Explique pourquoi l'accès est utile et rassure sur la confidentialité
///   (les chiffres restent dans le système, l'app ne les voit pas).
/// - Le CTA « Autoriser » déclenche `TempsEcranPermissionDemandee` → Bloc →
///   `ouvrirReglagesAcces` → `requestAuthorization` (FamilyControls).
/// - Réutilisé aussi pour l'état « refusé » : le CTA re-déclenche
///   la demande (comportement système : Apple peut afficher les réglages à la
///   place si l'utilisateur avait déjà refusé).
///
/// Ton bienveillant, a11y (tap ≥ 48dp, contraste AA), i18n 8 langues.
class VueAutorisationIos extends StatelessWidget {
  /// Crée la vue d'autorisation iOS.
  const VueAutorisationIos({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.lock_clock,
          size: 56,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.tempsEcranIosAutorisationTitre,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.tempsEcranIosAutorisationExplication,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton(
          onPressed: () {
            unawaited(HapticFeedback.lightImpact());
            context.read<TempsEcranBloc>().add(
              const TempsEcranPermissionDemandee(),
            );
          },
          child: Text(l10n.tempsEcranIosAutorisationCta),
        ),
      ],
    );
  }
}
