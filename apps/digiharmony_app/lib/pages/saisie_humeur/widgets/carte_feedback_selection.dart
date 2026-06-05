import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Carte de feedback affichée après un premier tap sur une pastille.
///
/// - En [EnregistrementEnCours] : libellé de l'émotion + indicateur de
///   chargement.
/// - En [EnregistrementReussi] : libellé uniquement (SnackBar prend le
///   relais).
/// - Invisible en [SaisieInitiale].
class CarteFeedbackSelection extends StatelessWidget {
  const CarteFeedbackSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaisieHumeurBloc, SaisieHumeurState>(
      builder: (context, state) {
        final l10n = context.l10n;

        final String? codeEmotion;
        final bool enCours;

        switch (state) {
          case EnregistrementEnCours():
            codeEmotion = state.codeEmotion;
            enCours = true;
          case EnregistrementReussi():
            codeEmotion = state.codeEmotion;
            enCours = false;
          case SaisieAnnuleeEtat():
            // Après annulation, réaffiche l'émotion restaurée si disponible.
            codeEmotion = state.codeEmotionRestauree;
            enCours = false;
          case SaisieInitiale():
          case EnregistrementEchoue():
            return const SizedBox.shrink();
        }

        if (codeEmotion == null) return const SizedBox.shrink();

        final libelle = _libelleEmotion(context, codeEmotion);
        final couleur = MoodColors.byKey[codeEmotion] ?? AppColors.primary;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.saisieHumeurSelectionne(libelle),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: couleur,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (enCours) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.saisieHumeurEnregistrementEnCours,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
                if (enCours) ...[
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: couleur,
                    ),
                  ),
                ],
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
