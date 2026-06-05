import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Données d'une particule flottante.
class _ParticuleDonnees {
  const _ParticuleDonnees({
    required this.left,
    required this.top,
    required this.size,
    required this.couleur,
    required this.delayMs,
    required this.icon,
  });

  final double left;
  final double top;
  final double size;
  final Color couleur;
  final int delayMs;
  final IconData icon;
}

/// Décor de particules flottantes en fond.
///
/// a11y : si `MediaQuery.disableAnimations` est vrai, les particules sont
/// statiques (RM-2 — DEC-HOME-07).
class ParticulesFlottantes extends StatelessWidget {
  /// Crée les particules flottantes.
  const ParticulesFlottantes({super.key});

  static const List<_ParticuleDonnees> _particules = [
    _ParticuleDonnees(
      left: 30,
      top: 120,
      size: 16,
      couleur: AppColors.primaryLight,
      delayMs: 0,
      icon: Icons.circle,
    ),
    _ParticuleDonnees(
      left: 280,
      top: 200,
      size: 12,
      couleur: AppColors.accentGold,
      delayMs: 800,
      icon: Icons.star,
    ),
    _ParticuleDonnees(
      left: 150,
      top: 60,
      size: 10,
      couleur: AppColors.primaryLight,
      delayMs: 1600,
      icon: Icons.circle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Stack(
        children: _particules.map((p) {
          final particule = Positioned(
            left: p.left,
            top: p.top,
            child: Icon(p.icon, size: p.size, color: p.couleur),
          );

          if (disableAnimations) return particule;

          return Positioned(
            left: p.left,
            top: p.top,
            child: Icon(p.icon, size: p.size, color: p.couleur)
                .animate(
                  delay: Duration(milliseconds: p.delayMs),
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .moveY(
                  begin: 0,
                  end: -12,
                  duration: const Duration(milliseconds: 2400),
                  curve: Curves.easeInOut,
                )
                .fade(
                  begin: 0.5,
                  end: 1,
                  duration: const Duration(milliseconds: 2400),
                ),
          );
        }).toList(),
      ),
    );
  }
}
