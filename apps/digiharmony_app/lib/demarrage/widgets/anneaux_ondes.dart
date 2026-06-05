import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 3 anneaux d'ondes concentriques (diamètres 150 / 190 / 230 px).
///
/// En mode normal : expansion/pulse en boucle, opacité décroissante par anneau.
/// Si [animer] est `false` (reduced motion), anneaux **statiques** (repos).
class AnneauxOndes extends StatelessWidget {
  /// Crée les anneaux d'ondes. [animer] pilote la boucle.
  const AnneauxOndes({required this.animer, super.key});

  /// Active la boucle de pulsation (désactivée en reduced motion).
  final bool animer;

  static const List<double> _diametres = [150, 190, 230];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (var i = 0; i < _diametres.length; i++)
          _anneau(_diametres[i], 0.30 - i * 0.08, i),
      ],
    );
  }

  Widget _anneau(double diametre, double opacite, int index) {
    final anneau = Container(
      width: diametre,
      height: diametre,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: opacite.clamp(0, 1)),
        ),
      ),
    );

    if (!animer) return anneau;

    return anneau
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 0.95,
          end: 1.05,
          duration: 2600.ms,
          delay: (index * 200).ms,
          curve: Curves.easeInOut,
        );
  }
}
