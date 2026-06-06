import 'package:digiharmony_app/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart';
import 'package:digiharmony_app/pages/saisie_humeur/modeles/emotion_canonique.dart';
import 'package:digiharmony_app/pages/saisie_humeur/widgets/pastille_emotion.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Grille des 7 pastilles d'émotion.
///
/// Réactif à l'état du [SaisieHumeurBloc] :
/// - Sélection courante → anneau sur la pastille correspondante.
/// - Le picker reste interactif tant que l'utilisateur n'a pas validé
///   (re-sélection libre avant validation).
/// - Verrouillé seulement pendant l'enregistrement et après succès.
class PickerEmotions extends StatelessWidget {
  const PickerEmotions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaisieHumeurBloc, SaisieHumeurState>(
      builder: (context, state) {
        final codeSelectionne = state.codeSelectionne;
        // Picker verrouillé pendant l'UPSERT et après succès (avant le pop).
        final desactive =
            state is EnregistrementEnCours || state is EnregistrementReussi;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          alignment: WrapAlignment.center,
          children: emotionsCanoniques.indexed.map(((int, EmotionCanonique) e) {
            final (idx, emotion) = e;
            return PastilleEmotion(
              key: ValueKey(emotion.cle),
              emotion: emotion,
              selectionne: emotion.cle == codeSelectionne,
              desactive: desactive,
              index: idx,
            );
          }).toList(),
        );
      },
    );
  }
}
