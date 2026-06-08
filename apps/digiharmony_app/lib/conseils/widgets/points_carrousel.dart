import 'package:digiharmony_app/theme/theme_application.dart';
import 'package:flutter/material.dart';

/// Indicateur de cartes : N points, l'actif rendu comme une barre allongee
/// a la couleur de l'emotion courante.
class PointsCarrousel extends StatelessWidget {
  /// {@macro points_carrousel}
  const PointsCarrousel({
    required this.current,
    required this.total,
    required this.activeColor,
    super.key,
  });

  /// Index de la carte active.
  final int current;

  /// Nombre total de cartes.
  final int total;

  /// Couleur de la barre active (= couleur de l'emotion courante).
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == current ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == current
                  ? activeColor
                  : ThemeApplication.muted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
