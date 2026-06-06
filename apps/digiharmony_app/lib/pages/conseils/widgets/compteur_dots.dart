import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Indicateur de position du deck (dots + pilule active).
///
/// Le point actif est élargi en pilule et coloré par [accentCourant].
/// Les inactifs sont atténués. C'est un indicateur de POSITION, jamais un
/// score (DEC-003 + DEC-CO-09).
///
/// a11y : [Semantics] annonce la carte courante (conseilsCompteurSemantique).
class CompteurDots extends StatelessWidget {
  /// Crée le compteur de points.
  const CompteurDots({
    required this.total,
    required this.indexCourant,
    required this.accentCourant,
    this.label,
    super.key,
  });

  /// Nombre total de cartes dans le deck.
  final int total;

  /// Index de la carte active (0-based).
  final int indexCourant;

  /// Couleur de la pilule active (= accent de la carte courante).
  final Color accentCourant;

  /// Label a11y (ex. « Carte 2 sur 4 »).
  final String? label;

  static const double _dotHeight = 6;
  static const double _dotWidthInactive = 6;
  static const double _dotWidthActive = 20;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(total, (i) {
          final active = i == indexCourant;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? _dotWidthActive : _dotWidthInactive,
            height: _dotHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_dotHeight / 2),
              color: active
                  ? accentCourant
                  : AppColors.textMuted.withValues(alpha: 0.22),
            ),
          );
        }),
      ),
    );
  }
}
