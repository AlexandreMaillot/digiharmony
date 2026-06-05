import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Barre dégradée « signature » de la marque (88×3 px).
///
/// Dégradé horizontal = `AppColors.signatureGradient` (valeurs canoniques
/// `#3FB8E6 → #A8D24E → #F0C84A`, DEC-S-008). Aucune couleur en dur.
class BarreSignature extends StatelessWidget {
  /// Crée la barre signature.
  const BarreSignature({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 3,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.signatureGradient,
        ),
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    );
  }
}
