/// Widget utilitaire : feedback de tap animé (scale + haptique).
///
/// Surface tappable propre :
///   - [Material] transparent (pour InkWell a11y)
///   - [InkWell] sans ripple visible (splash/highlight transparents)
///   - [AnimatedScale] au tap-down via [InkWell.onHighlightChanged]
///   - [HapticFeedback.selectionClick] au tap
///   - [Semantics] configurable
///
/// En reduced-motion : pas de scale, garde l'haptique + onTap.
/// Focus clavier conservé via [InkWell].
/// Pas de double feedback : un seul callback onTap.
/// Nommage FR conformément aux conventions du projet.
library;

import 'dart:async';

import 'package:digiharmony_app/common/anim/anim_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enrobage de feedback de tap animé avec surface tappable propre.
///
/// Usage :
/// ```dart
/// TapAnime(
///   onTap: () => /* action */,
///   borderRadius: AppRadii.cardRadius,
///   child: MonWidget(),
/// )
/// ```
class TapAnime extends StatefulWidget {
  /// Crée un widget avec feedback de tap animé.
  const TapAnime({
    required this.child,
    required this.onTap,
    this.borderRadius,
    this.semanticsLabel,
    this.estBouton = true,
    super.key,
  });

  /// Widget enfant à animer.
  final Widget child;

  /// Callback déclenché au tap.
  final VoidCallback onTap;

  /// Rayon des coins pour l'InkWell et le Material.
  final BorderRadius? borderRadius;

  /// Label sémantique optionnel (accessible).
  final String? semanticsLabel;

  /// Indique si le widget doit être annoté comme bouton en sémantique.
  final bool estBouton;

  @override
  State<TapAnime> createState() => _TapAnimeState();
}

class _TapAnimeState extends State<TapAnime> {
  bool _appuye = false;

  void _onHighlightChanged(bool val) {
    if (!mounted) return;
    setState(() => _appuye = val);
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final inkWell = InkWell(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        widget.onTap();
      },
      onHighlightChanged: disableAnimations ? null : _onHighlightChanged,
      borderRadius: widget.borderRadius,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: widget.child,
    );

    final surface = Material(
      type: MaterialType.transparency,
      borderRadius: widget.borderRadius,
      child: inkWell,
    );

    final contenu = Semantics(
      label: widget.semanticsLabel,
      button: widget.estBouton,
      child: surface,
    );

    // En reduced-motion : pas de scale.
    if (disableAnimations) return contenu;

    return AnimatedScale(
      scale: _appuye ? scaleTap : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: contenu,
    );
  }
}
