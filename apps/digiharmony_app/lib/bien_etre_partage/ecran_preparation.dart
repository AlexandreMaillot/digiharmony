import 'dart:async';

import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Écran de préparation partagé (respiration / sens / étirement).
///
/// Icône + phrase rassurante + décompte 3-2-1 animé, **sans audio**. Affiché
/// avant le démarrage de l'exercice. [phrase] est résolue par l'appelant
/// (clé i18n propre à chaque exercice), [compteur] vient du Bloc.
class EcranPreparation extends StatelessWidget {
  /// Crée l'écran de préparation.
  const EcranPreparation({
    required this.phrase,
    required this.compteur,
    this.couleur = AppColors.successVert,
    super.key,
  });

  /// Phrase d'introduction (ex. « Prépare-toi… »).
  final String phrase;

  /// Secondes restantes du décompte (3 → 1).
  final int compteur;

  /// Couleur d'accent (par défaut le vert de réussite).
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.self_improvement, size: 56, color: couleur),
          const SizedBox(height: 24),
          Text(
            phrase,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 40),
          CompteurPreparation(valeur: compteur, couleur: couleur),
        ],
      ),
    );
  }
}

/// Chiffre du décompte avec animation « pop » (scale élastique + fondu) à
/// chaque changement. `StatefulWidget` dédié (la vue parente reste Stateless) ;
/// respecte `reduceMotion`.
class CompteurPreparation extends StatefulWidget {
  /// Crée le compteur animé.
  const CompteurPreparation({
    required this.valeur,
    this.couleur = AppColors.successVert,
    super.key,
  });

  /// Valeur affichée (3, 2, 1).
  final int valeur;

  /// Couleur du chiffre.
  final Color couleur;

  @override
  State<CompteurPreparation> createState() => _CompteurPreparationState();
}

class _CompteurPreparationState extends State<CompteurPreparation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _premier = true;

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 1,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_premier) {
      _premier = false;
      if (!_reduceMotion) unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void didUpdateWidget(CompteurPreparation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valeur != widget.valeur && !_reduceMotion) {
      unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chiffre = Text(
      '${widget.valeur}',
      style: TextStyle(
        color: widget.couleur,
        fontSize: 96,
        fontWeight: FontWeight.bold,
      ),
    );
    if (_reduceMotion) return chiffre;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final scale = 0.5 + 0.5 * Curves.elasticOut.transform(t);
        return Opacity(
          opacity: Curves.easeOut.transform(t),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: chiffre,
    );
  }
}
