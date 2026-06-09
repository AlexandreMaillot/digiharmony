import 'dart:async';
import 'dart:math' as math;

import 'package:digiharmony_app/pages/detox/widgets/detox_fleur_painter.dart';
import 'package:flutter/material.dart';

/// Fleur animée de la Détox (8 pétales + arc de progression).
///
/// Seul StatefulWidget autorisé dans la feature Détox : isole le
/// controller d'animation et le check reduceMotion. La View parente
/// reste Stateless et passe [progress] / [bloomProgress] comme données pures.
///
/// Le degré d'épanouissement et l'arc restent pilotés par la progression
/// du timer (argument entrant), pas purement décoratifs.
class FleurDetoxAnimee extends StatefulWidget {
  /// {@macro fleur_detox_animee}
  const FleurDetoxAnimee({
    required this.progress,
    required this.bloomProgress,
    super.key,
  });

  /// Avancement 0->1 de l'arc de progression.
  final double progress;

  /// Degré d'ouverture 0->1 des pétales.
  final double bloomProgress;

  @override
  State<FleurDetoxAnimee> createState() => _FleurDetoxAnimeeState();
}

class _FleurDetoxAnimeeState extends State<FleurDetoxAnimee>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  /// Animation décorative en boucle : rotation lente + pulsation douce de la
  /// fleur (purement esthétique, coupée si reduceMotion).
  late final AnimationController _decorController;

  late Animation<double> _progressAnim;
  late Animation<double> _bloomAnim;

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _decorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );
    unawaited(_decorController.repeat());
    _progressAnim = Tween<double>(
      begin: widget.progress,
      end: widget.progress,
    ).animate(_controller);
    _bloomAnim = Tween<double>(
      begin: widget.bloomProgress,
      end: widget.bloomProgress,
    ).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Coupe/relance l'animation décorative selon la préférence d'accessibilité.
    if (_reduceMotion) {
      _decorController.stop();
    } else if (!_decorController.isAnimating) {
      unawaited(_decorController.repeat());
    }
  }

  @override
  void didUpdateWidget(FleurDetoxAnimee old) {
    super.didUpdateWidget(old);
    if (old.progress == widget.progress &&
        old.bloomProgress == widget.bloomProgress) {
      return;
    }

    if (_reduceMotion) {
      setState(() {
        _progressAnim = AlwaysStoppedAnimation(widget.progress);
        _bloomAnim = AlwaysStoppedAnimation(widget.bloomProgress);
      });
      return;
    }

    final currentProgress = _progressAnim.value;
    final currentBloom = _bloomAnim.value;
    _controller.reset();
    _progressAnim = Tween<double>(
      begin: currentProgress,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _bloomAnim = Tween<double>(
      begin: currentBloom,
      end: widget.bloomProgress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _decorController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _decorController]),
      builder: (context, _) {
        // Couche PÉTALES : tourne + pulse (décoratif).
        Widget petales = SizedBox(
          width: 280,
          height: 280,
          child: CustomPaint(
            painter: DetoxFleurPainter(
              progress: 0,
              bloomProgress: _bloomAnim.value,
              peindreArc: false,
            ),
          ),
        );
        if (!_reduceMotion) {
          final t = _decorController.value; // 0 -> 1 en boucle
          // Rotation lente sur elle-même (un tour toutes les 14 s).
          final angle = t * 2 * math.pi;
          // Pulsation douce : ~±5 % toutes les ~2,8 s (5 cycles par tour).
          final echelle = 1 + 0.05 * math.sin(t * 2 * math.pi * 5);
          petales = Transform.rotate(
            angle: angle,
            child: Transform.scale(scale: echelle, child: petales),
          );
        }
        // Couche ARC de progression : FIXE (ne tourne pas, ne pulse pas).
        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              petales,
              SizedBox(
                width: 280,
                height: 280,
                child: CustomPaint(
                  painter: DetoxFleurPainter(
                    progress: _progressAnim.value,
                    bloomProgress: 0,
                    peindrePetales: false,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
