/// Widget utilitaire : feedback de tap animé (scale + haptique).
///
/// - En reduced-motion : pas de scale, mais garde l'haptique et le onTap.
/// - Accessible : tap target >= 48 dp inchangée.
/// - Nommage FR conformément aux conventions du projet.
library;

import 'dart:async';

import 'package:digiharmony_app/common/anim/anim_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enrobage de feedback de tap animé.
///
/// Usage :
/// ```dart
/// TapAnime(
///   onTap: () => /* action */,
///   child: MonWidget(),
/// )
/// ```
class TapAnime extends StatefulWidget {
  /// Crée un widget avec feedback de tap animé.
  const TapAnime({
    required this.child,
    required this.onTap,
    this.borderRadius,
    super.key,
  });

  /// Widget enfant à animer.
  final Widget child;

  /// Callback déclenché au tap.
  final VoidCallback onTap;

  /// Rayon des coins pour la zone de tap (Semantics/InkWell-like).
  final BorderRadius? borderRadius;

  @override
  State<TapAnime> createState() => _TapAnimeState();
}

class _TapAnimeState extends State<TapAnime> {
  bool _appuye = false;

  void _onTapDown(TapDownDetails _) {
    if (!mounted) return;
    setState(() => _appuye = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (!mounted) return;
    setState(() => _appuye = false);
    unawaited(HapticFeedback.selectionClick());
    widget.onTap();
  }

  void _onTapCancel() {
    if (!mounted) return;
    setState(() => _appuye = false);
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    // En reduced-motion : pas de scale mais on garde l'haptique + onTap.
    if (disableAnimations) {
      return GestureDetector(
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          widget.onTap();
        },
        child: widget.child,
      );
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _appuye ? scaleTap : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
