/// Widget utilitaire : animation d'entrée douce (fadeIn + slideY).
///
/// - No-op si `MediaQuery.maybeOf(context)?.disableAnimations == true`.
///   Dans ce cas, le child est retourné directement sans wrapper.
/// - Supporte une cascade via `index` : `delay = index x decalageCascade`.
/// - Le paramètre `delay` permet de surcharger le délai calculé.
library;

import 'package:digiharmony_app/common/anim/anim_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Enrobage d'animation d'entrée douce.
///
/// Usage simple :
/// ```dart
/// EntreeDouce(child: MonWidget())
/// ```
///
/// Usage cascade :
/// ```dart
/// EntreeDouce(index: 0, child: PremierItem())
/// EntreeDouce(index: 1, child: DeuxiemeItem())
/// ```
class EntreeDouce extends StatelessWidget {
  /// Crée une entrée douce.
  const EntreeDouce({
    required this.child,
    this.index = 0,
    this.delay,
    super.key,
  });

  /// Widget à animer.
  final Widget child;

  /// Position dans la cascade (0 = premier). Utilisé pour calculer le délai.
  final int index;

  /// Délai explicite. Si fourni, remplace `index × decalageCascade`.
  final Duration? delay;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    // No-op en reduced-motion : état final immédiat, pas d'opacité 0 figée.
    if (disableAnimations) return child;

    final delaiEffectif = delay ?? (decalageCascade * index);

    return child
        .animate()
        .fadeIn(
          duration: dureeEntree,
          delay: delaiEffectif,
          curve: curveEntree,
        )
        .slideY(
          begin: offsetEntree,
          end: 0,
          duration: dureeEntree,
          delay: delaiEffectif,
          curve: curveEntree,
        );
  }
}
