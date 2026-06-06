import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart';
import 'package:digiharmony_app/pages/saisie_humeur/modeles/emotion_canonique.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Carte de feedback affichée dès qu'une émotion est sélectionnée.
///
/// Reprend le visuel de la maquette : pastille emoji
/// + « Tu as sélectionné : X » + icône de validation.
/// L'enregistrement étant instantané, aucun indicateur
/// « Enregistrement en cours… » n'est affiché. Invisible à l'état initial.
class CarteFeedbackSelection extends StatelessWidget {
  const CarteFeedbackSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaisieHumeurBloc, SaisieHumeurState>(
      builder: (context, state) {
        final l10n = context.l10n;
        final codeEmotion = state.codeSelectionne;
        if (codeEmotion == null) return const SizedBox.shrink();

        final libelle = _libelleEmotion(context, codeEmotion);
        final couleur = MoodColors.byKey[codeEmotion] ?? AppColors.primary;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Pastille emoji colorée.
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: couleur.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    emojiPourCode(codeEmotion),
                    style: const TextStyle(fontSize: 24),
                    semanticsLabel: libelle,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.saisieHumeurSelectionne(libelle),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: couleur,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.check_circle, color: couleur),
              ],
            ),
          ),
        );
      },
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
