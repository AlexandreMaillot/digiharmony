import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Bouton « Recommencer » partage par les exercices.
class BoutonRecommencer extends StatelessWidget {
  /// {@macro bouton_recommencer}
  const BoutonRecommencer({
    required this.label,
    required this.onTap,
    this.icon = Icons.refresh,
    super.key,
  });

  /// Libelle du bouton (resolu depuis l'ARB).
  final String label;

  /// Callback du tap.
  final VoidCallback onTap;

  /// Icone du bouton.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
    );
  }
}
