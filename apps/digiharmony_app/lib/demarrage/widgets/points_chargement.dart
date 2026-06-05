import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 3 « loading dots » : le central plus gros, pulsation séquentielle.
///
/// Si [animer] est `false` (reduced motion, DEC-S-005), les dots sont
/// **statiques** (présents et lisibles, sans boucle).
class PointsChargement extends StatelessWidget {
  /// Crée les points de chargement. [animer] pilote la pulsation.
  const PointsChargement({required this.animer, super.key});

  /// Active la boucle de pulsation (désactivée en reduced motion).
  final bool animer;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _point(taille: 6, index: 0),
        const SizedBox(width: AppSpacing.sm),
        _point(taille: 9, index: 1),
        const SizedBox(width: AppSpacing.sm),
        _point(taille: 6, index: 2),
      ],
    );
  }

  Widget _point({required double taille, required int index}) {
    final point = Container(
      width: taille,
      height: taille,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLight,
      ),
    );

    if (!animer) return point;

    return point
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(
          begin: 0.3,
          duration: 600.ms,
          delay: (index * 200).ms,
        );
  }
}
