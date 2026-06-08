import 'dart:async';

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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => SizedBox(
        width: 280,
        height: 280,
        child: CustomPaint(
          painter: DetoxFleurPainter(
            progress: _progressAnim.value,
            bloomProgress: _bloomAnim.value,
          ),
        ),
      ),
    );
  }
}
