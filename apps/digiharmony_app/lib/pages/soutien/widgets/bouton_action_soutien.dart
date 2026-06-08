import 'dart:async';

import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Style du bouton d'action de l'écran de soutien.
enum StyleBoutonSoutien {
  /// Bouton rempli (action principale).
  primaire,

  /// Bouton outline/ghost (action secondaire).
  secondaire,
}

/// Bouton d'action large pour l'écran de soutien.
///
/// Zone tactile >= 48×48 dp (DEC-SO-010).
/// [HapticFeedback.lightImpact] au tap (discret).
/// Aucun hex en dur : tokens [AppColors]/[AppRadii].
class BoutonActionSoutien extends StatelessWidget {
  /// Crée un bouton d'action de soutien.
  const BoutonActionSoutien({
    required this.icone,
    required this.label,
    required this.onTap,
    required this.style,
    this.semanticsLabel,
    super.key,
  });

  /// Icône affichée à gauche du label.
  final IconData icone;

  /// Texte du bouton.
  final String label;

  /// Callback au tap.
  final VoidCallback onTap;

  /// Style visuel du bouton.
  final StyleBoutonSoutien style;

  /// Label de sémantique pour l'accessibilité.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? label,
      button: true,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: style == StyleBoutonSoutien.primaire
            ? ElevatedButton.icon(
                onPressed: () {
                  unawaited(HapticFeedback.lightImpact());
                  onTap();
                },
                icon: Icon(icone),
                label: Text(label),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDeep,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.buttonRadius,
                  ),
                  minimumSize: const Size(48, 48),
                ),
              )
            : OutlinedButton.icon(
                onPressed: () {
                  unawaited(HapticFeedback.lightImpact());
                  onTap();
                },
                icon: Icon(icone, color: AppColors.primary),
                label: Text(
                  label,
                  style: const TextStyle(color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.buttonRadius,
                  ),
                  minimumSize: const Size(48, 48),
                ),
              ),
      ),
    );
  }
}
