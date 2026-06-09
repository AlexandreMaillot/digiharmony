import 'dart:math' as math;

import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Peint la fleur a 8 petales + l'arc de progression, pilotes par le timer.
///
/// `progress` -> avancement de l'arc ; `bloomProgress` -> ouverture des
/// petales. Aucune boucle decorative ici (purement information).
class DetoxFleurPainter extends CustomPainter {
  /// {@macro detox_fleur_painter}
  DetoxFleurPainter({
    required this.progress,
    required this.bloomProgress,
    this.peindrePetales = true,
    this.peindreArc = true,
  });

  /// Avancement 0->1 de l'arc.
  final double progress;

  /// Degre d'ouverture 0->1 des petales.
  final double bloomProgress;

  /// Peint les 8 petales (la fleur). Permet de dessiner la fleur et l'arc dans
  /// deux couches separees (ex. fleur animee, arc fixe).
  final bool peindrePetales;

  /// Peint l'arc de progression + le point central.
  final bool peindreArc;

  static const List<Color> _gradient = <Color>[
    AppColors.primary,
    AppColors.successVert,
    AppColors.sensesAccentOr,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 12;

    // 8 petales.
    final eased = Curves.easeOut.transform(bloomProgress.clamp(0.0, 1.0));
    if (peindrePetales) {
      for (var i = 0; i < 8; i++) {
        final angle = i * (2 * math.pi / 8);
        final petalLength = radius * (0.35 + 0.55 * eased);
        final tip = Offset(
          center.dx + petalLength * math.cos(angle),
          center.dy + petalLength * math.sin(angle),
        );
        final color = _gradient[i % _gradient.length].withValues(
          alpha: 0.35 + 0.4 * eased,
        );
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..quadraticBezierTo(
            center.dx + petalLength * 0.5 * math.cos(angle - 0.4),
            center.dy + petalLength * 0.5 * math.sin(angle - 0.4),
            tip.dx,
            tip.dy,
          )
          ..quadraticBezierTo(
            center.dx + petalLength * 0.5 * math.cos(angle + 0.4),
            center.dy + petalLength * 0.5 * math.sin(angle + 0.4),
            center.dx,
            center.dy,
          );
        canvas.drawPath(path, paint);
      }
    }

    // Arc de progression (+ point central). Couche fixe : ne tourne pas.
    if (peindreArc) {
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(colors: _gradient).createShader(
          Rect.fromCircle(center: center, radius: radius),
        );
      canvas
        ..drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          2 * math.pi * progress.clamp(0.0, 1.0),
          false,
          arcPaint,
        )
        ..drawCircle(
          center,
          8,
          Paint()..color = AppColors.text.withValues(alpha: 0.8),
        );
    }
  }

  @override
  bool shouldRepaint(covariant DetoxFleurPainter old) =>
      old.progress != progress || old.bloomProgress != bloomProgress;
}
