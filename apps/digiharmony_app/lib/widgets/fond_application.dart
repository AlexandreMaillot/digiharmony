import 'package:digiharmony_app/theme/theme_application.dart';
import 'package:flutter/material.dart';

/// Fond partage des ecrans : couleur bleu nuit + 2 halos radiaux decoratifs.
///
/// `background` permet de surcharger la couleur (defaut = fond bulle #16213C).
/// Les halos sont purement decoratifs et statiques (aucune boucle d'animation
/// pour respecter `reduceMotion` par construction).
class FondApplication extends StatelessWidget {
  /// {@macro fond_application}
  const FondApplication({
    required this.child,
    this.background,
    this.haloPrimary,
    this.haloSecondary,
    super.key,
  });

  /// Contenu pose au-dessus du fond.
  final Widget child;

  /// Couleur de fond (defaut = [ThemeApplication.bubbleBackground]).
  final Color? background;

  /// Couleur du 1er halo (defaut = primaire translucide).
  final Color? haloPrimary;

  /// Couleur du 2e halo (defaut = vert translucide).
  final Color? haloSecondary;

  @override
  Widget build(BuildContext context) {
    final bg = background ?? ThemeApplication.bubbleBackground;
    final h1 = haloPrimary ?? ThemeApplication.primary.withValues(alpha: 0.18);
    final h2 =
        haloSecondary ?? ThemeApplication.success.withValues(alpha: 0.12);

    return DecoratedBox(
      decoration: BoxDecoration(color: bg),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _Halo(color: h1, size: 320),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _Halo(color: h2, size: 360),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
