/// Transition de page douce : fadeIn + léger slideY.
///
/// - No-op (retourne child directement) si
///   `MediaQuery.of(context).disableAnimations`.
/// - Remplace les MaterialPageRoute dans AppRouter.
library;

import 'package:digiharmony_app/common/anim/anim_constants.dart';
import 'package:flutter/material.dart';

/// Crée une route avec transition douce.
///
/// La transition est : FadeTransition + léger SlideTransition (offset 0.02).
/// En reduced-motion, la transition est désactivée (affichage direct).
///
/// Usage :
/// ```dart
/// Navigator.of(context).push(routeDouce(MaPage()));
/// ```
Route<T> routeDouce<T>(
  Widget page, {
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: dureeTransitionPage,
    reverseTransitionDuration: dureeTransitionPage,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final disableAnimations =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;

      if (disableAnimations) return child;

      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: curveEntree,
      );

      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.02),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: curveEntree));

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: child,
        ),
      );
    },
  );
}
