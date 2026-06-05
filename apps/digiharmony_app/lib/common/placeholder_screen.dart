import 'dart:async';

import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Déclenche un retour haptique léger (sans permission `VIBRATE`) puis ouvre
/// un [PlaceholderScreen] portant le [titre] donné (push standard).
///
/// Centralise le geste « tap → haptique + placeholder » des destinations V1.
void ouvrirPlaceholder(BuildContext context, String titre) {
  unawaited(HapticFeedback.lightImpact());
  unawaited(
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlaceholderScreen(titre: titre),
      ),
    ),
  );
}

/// Écran neutre générique « Bientôt disponible ».
///
/// Cible provisoire des destinations non encore implémentées (V1).
/// Aucune couleur en dur : fond via le thème (`AppColors.background`).
class PlaceholderScreen extends StatelessWidget {
  /// Crée un écran placeholder portant le [titre] donné.
  const PlaceholderScreen({required this.titre, super.key});

  /// Titre affiché en haut et au centre de l'écran.
  final String titre;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(titre)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titre,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.placeholderComingSoon,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
