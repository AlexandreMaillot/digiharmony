import 'dart:async';

import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart';
import 'package:digiharmony_app/pages/saisie_humeur/modeles/emotion_canonique.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pastille circulaire représentant une émotion dans le picker.
///
/// - Taille fixe ~62 px (zone tactile ≥ 48×48 garantie par InkResponse).
/// - Couleur via [MoodColors.byKey] uniquement — jamais de hex en dur.
/// - Animation de flottement au repos (désactivée si `disableAnimations`).
/// - État sélectionné : anneau + halo coloré.
/// - État désactivé (picker verrouillé post-saisie) : opacité réduite.
class PastilleEmotion extends StatelessWidget {
  const PastilleEmotion({
    required this.emotion,
    required this.selectionne,
    required this.desactive,
    super.key,
  });

  /// L'émotion représentée par cette pastille.
  final EmotionCanonique emotion;

  /// Vrai si cette pastille est actuellement sélectionnée.
  final bool selectionne;

  /// Vrai si le picker est verrouillé (post-saisie réussie, DEC-SH-004).
  final bool desactive;

  @override
  Widget build(BuildContext context) {
    final couleur = MoodColors.byKey[emotion.cle];
    final libelle = _libelleEmotion(context, emotion.cle);
    final disableAnimations =
        MediaQuery.disableAnimationsOf(context);

    Widget pastille = _PastilleBody(
      emotion: emotion,
      couleur: couleur,
      libelle: libelle,
      selectionne: selectionne,
    );

    if (!disableAnimations && !desactive) {
      pastille = pastille
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: -4,
            duration: const Duration(milliseconds: 2000),
            curve: Curves.easeInOut,
          );
    }

    return Opacity(
      opacity: desactive && !selectionne ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: desactive
            ? null
            : () {
                unawaited(HapticFeedback.lightImpact());
                context
                    .read<SaisieHumeurBloc>()
                    .add(EmotionTapee(emotion.cle));
              },
        child: SizedBox(
          width: 80,
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
                      fontWeight: selectionne
                          ? FontWeight.w600
                          : FontWeight.normal,
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

  String _libelleEmotion(BuildContext context, String cle) {
    final l10n = context.l10n;
    switch (cle) {
      case 'happy':
        return l10n.moodHappy;
      case 'calm':
        return l10n.moodCalm;
      case 'dynamic':
        return l10n.moodDynamic;
      case 'sad':
        return l10n.moodSad;
      case 'angry':
        return l10n.moodAngry;
      case 'nervous':
        return l10n.moodNervous;
      case 'tired':
        return l10n.moodTired;
      default:
        return cle;
    }
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
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: couleur != null
            ? couleur!.withValues(alpha: 0.18)
            : AppColors.surface,
        shape: BoxShape.circle,
        border: selectionne && couleur != null
            ? Border.all(color: couleur!, width: 2.5)
            : null,
        boxShadow: selectionne && couleur != null
            ? [
                BoxShadow(
                  color: couleur!.withValues(alpha: 0.40),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          emotion.emoji,
          style: const TextStyle(fontSize: 28),
          semanticsLabel: libelle,
        ),
      ),
    );
  }
}
