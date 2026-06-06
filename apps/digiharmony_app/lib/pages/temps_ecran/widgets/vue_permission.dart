import 'dart:async';

import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/temps_ecran/bloc/temps_ecran_bloc.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Écran d'explication AVANT l'accès natif (DEC-TE-02 / §5.2).
///
/// Explique pourquoi l'accès est utile + rassure sur la confidentialité ;
/// seul le tap sur le CTA déclenche l'ouverture des réglages système.
class VuePermission extends StatelessWidget {
  /// Crée la vue permission.
  const VuePermission({super.key});

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
          l10n.tempsEcranPermissionTitre,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.tempsEcranPermissionExplication,
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
          child: Text(l10n.tempsEcranPermissionCta),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.tempsEcranPermissionRassurance,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
