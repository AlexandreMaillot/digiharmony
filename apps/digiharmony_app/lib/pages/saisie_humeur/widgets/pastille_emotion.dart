import 'dart:async';

import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart';
import 'package:digiharmony_app/pages/saisie_humeur/modeles/emotion_canonique.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Delays de flottement par index de pastille (inspirés de la maquette).
///
/// Pill-0..6 : 0 ms, 600 ms, 1100 ms, 300 ms, 1800 ms, 900 ms, 1400 ms.
/// Valeurs déterministes ; au-delà de 6 : modulo sur la liste.
const List<int> _flotDelay = [0, 600, 1100, 300, 1800, 900, 1400];

/// Durées légèrement différenciées (ms) pour casser le synchronisme visuel.
const List<int> _flotDuration = [2000, 1800, 2200, 1900, 2100, 1700, 2300];

/// Pastille circulaire représentant une émotion dans le picker.
///
/// - Taille fixe ~96 px (zone tactile ≥ 48×48 garantie par GestureDetector).
/// - Couleur via [MoodColors.byKey] uniquement — jamais de hex en dur.
/// - Animation de flottement au repos désynchronisée par [index]
///   (désactivée si `disableAnimations`).
/// - État sélectionné : anneau + halo coloré.
/// - État désactivé (picker verrouillé post-saisie) : opacité réduite.
class PastilleEmotion extends StatelessWidget {
  const PastilleEmotion({
    required this.emotion,
    required this.selectionne,
    required this.desactive,
    required this.index,
    super.key,
  });

  /// L'émotion représentée par cette pastille.
  final EmotionCanonique emotion;

  /// Vrai si cette pastille est actuellement sélectionnée.
  final bool selectionne;

  /// Vrai si le picker est verrouillé (post-saisie réussie, DEC-SH-004).
  final bool desactive;

  /// Position dans la grille (0-based) — détermine le delay et la durée du
  /// flottement pour désynchroniser les pastilles les unes des autres.
  final int index;

  @override
  Widget build(BuildContext context) {
    final couleur = MoodColors.byKey[emotion.cle];
    final libelle = libelleEmotion(context.l10n, emotion.cle);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    Widget pastille = _PastilleBody(
      emotion: emotion,
      couleur: couleur,
      libelle: libelle,
      selectionne: selectionne,
    );

    if (!disableAnimations) {
      if (selectionne) {
        // Pop prononcé à la sélection (rebond élastique) — la clé par émotion
        // force le rejeu de l'animation quand une nouvelle pastille devient
        // sélectionnée. Le halo (boxShadow) est porté par `_PastilleBody`.
        pastille = pastille
            .animate(key: ValueKey('selection-${emotion.cle}'))
            .scaleXY(
              begin: 0.82,
              end: 1,
              duration: const Duration(milliseconds: 450),
              curve: Curves.elasticOut,
            );
      } else if (!desactive) {
        final i = index % _flotDelay.length;
        pastille = pastille
            .animate(
              onPlay: (c) => c.repeat(reverse: true),
              delay: Duration(milliseconds: _flotDelay[i]),
            )
            .moveY(
              begin: 0,
              end: -4,
              duration: Duration(milliseconds: _flotDuration[i]),
              curve: Curves.easeInOut,
            );
      }
    }

    return Opacity(
      opacity: desactive && !selectionne ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: desactive
            ? null
            : () {
                unawaited(HapticFeedback.lightImpact());
                context.read<SaisieHumeurBloc>().add(
                  EmotionSelectionnee(emotion.cle),
                );
              },
        child: SizedBox(
          width: 96,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              pastille,
              const SizedBox(height: AppSpacing.xs),
              Text(
                libelle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selectionne
                      ? (couleur ?? AppColors.primary)
                      : AppColors.textMuted,
                  fontWeight: selectionne ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PastilleBody extends StatelessWidget {
  const _PastilleBody({
    required this.emotion,
    required this.couleur,
    required this.libelle,
    required this.selectionne,
  });

  final EmotionCanonique emotion;
  final Color? couleur;
  final String libelle;
  final bool selectionne;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: couleur != null
            ? couleur!.withValues(alpha: 0.18)
            : AppColors.surface,
        shape: BoxShape.circle,
        border: selectionne && couleur != null
            ? Border.all(color: couleur!, width: 3)
            : null,
        // Halo prononcé à la sélection : double lueur (proche + diffuse) pour
        // l'effet « glow » de la maquette.
        boxShadow: selectionne && couleur != null
            ? [
                BoxShadow(
                  color: couleur!.withValues(alpha: 0.55),
                  blurRadius: 28,
                  spreadRadius: 6,
                ),
                BoxShadow(
                  color: couleur!.withValues(alpha: 0.28),
                  blurRadius: 48,
                  spreadRadius: 12,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          emotion.emoji,
          style: const TextStyle(fontSize: 46),
          semanticsLabel: libelle,
        ),
      ),
    );
  }
}
